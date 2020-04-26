from typing import Dict, Tuple, List
import logging

from overrides import overrides
from conllu import parse_incr

from allennlp.common.file_utils import cached_path
from allennlp.data.dataset_readers.dataset_reader import DatasetReader
from allennlp.data.fields import Field, TextField, ArrayField, SequenceLabelField, MetadataField
from allennlp.data.instance import Instance
from allennlp.data.token_indexers import SingleIdTokenIndexer, TokenIndexer
from allennlp.data.tokenizers import Token, Tokenizer

import numpy as np

logger = logging.getLogger(__name__)


@DatasetReader.register("wordpiece_ner")
class NERWordpieceReader(DatasetReader):
    def __init__(
        self,
        token_indexers: Dict[str, TokenIndexer] = None,
        use_language_specific_pos: bool = False,
        tokenizer: Tokenizer = None,
        lazy: bool = False,
    ) -> None:
        super().__init__(lazy)
        self._token_indexers = token_indexers or {"tokens": SingleIdTokenIndexer()}
        self.use_language_specific_pos = use_language_specific_pos
        self.tokenizer = tokenizer

    @overrides
    def _read(self, file_path: str):
        # if `file_path` is a URL, redirect to the cache
        file_path = cached_path(file_path)

        with open(file_path, "r") as ner_file:
            logger.info("Reading UD instances from NER dataset at: %s", file_path)

            words, ner_tags = [], []
            for line in ner_file:
                if not line.rstrip():
                    instance = self.text_to_instance(words, ner_tags)
                    words, ner_tags = [], []
                    if not instance:
                        continue
                    else:
                        yield instance

                else:
                    word, tag = line.rstrip("\n").split("\t")
                    words.append(word[3:])
                    ner_tags.append(tag)

    @overrides
    def text_to_instance(
        self,  # type: ignore
        words: List[str],
        ner_tags: List[str]
    ) -> Instance:

        """
        Parameters
        ----------
        words : ``List[str]``, required.
            The words in the sentence to be encoded.
        upos_tags : ``List[str]``, required.
            The universal dependencies POS tags for each word.

        Returns
        -------
        An instance containing words, upos tags, dependency head tags and head
        indices as fields.
        """
        fields: Dict[str, Field] = {}

        model_type = ""
        words = [i.replace(' ', '') for i in words]

        try:
            wordpieces = [Token(w) for w in self.tokenizer._tokenizer.wordpiece_tokenizer.tokenize(
                            "[CLS] " + " ".join(words) + " [SEP]")]
            model_type = "bert"
        except:
            wordpieces = [Token(w) for w in self.tokenizer._tokenizer.tokenize(
                            "[CLS] " + " ".join(words) + " [SEP]")]
            model_type = "xlm-r"

        if len(wordpieces) >= 512:
            return None

        # build map
        offsets = []
        for n, piece in enumerate(wordpieces):
            if model_type == "bert":
                if not piece.text.startswith('##'):
                    offsets.append(n)
            elif model_type == "xlm-r":
                if piece.text.startswith('▁'):  # NOT an underscore!
                    offsets.append(n)

        offsets = offsets[1:-1]
        tokens = [Token(t) for t in words]

        wordpiece_field = TextField(wordpieces, self._token_indexers)
        offset_field = ArrayField(np.array(offsets), dtype=np.long)

        text_field = TextField(tokens, self._token_indexers)
        fields["words"] = wordpiece_field
        fields["ner_tags"] = SequenceLabelField(ner_tags, text_field, label_namespace="ner")
        fields["offsets"] = offset_field

        fields["metadata"] = MetadataField({"words": words, "ner": ner_tags, "wordpieces": wordpieces})
        return Instance(fields)
