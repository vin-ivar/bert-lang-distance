from argparse import ArgumentParser

from allennlp.commands.train import train_model
from allennlp.commands.fine_tune import fine_tune_model
from allennlp.training.trainer import Params
from allennlp.common.util import import_submodules

from allennlp.data.dataset_readers import DatasetReader
from allennlp.models.model import Model
from allennlp.predictors import Predictor

import os
import torch
import numpy as np

def main():
    parser = ArgumentParser()
    parser.add_argument('--train', action='store')
    parser.add_argument('--finetune', action='store')
    parser.add_argument('--val_train', action='store')
    parser.add_argument('--val_finetune', action='store')
    parser.add_argument('--config', action='store', default='./configs/debug.jsonnet')
    parser.add_argument('--save', action='store', default='experiments/models/default')
    args = parser.parse_args()

    import_submodules("model")
    import_submodules("loader")
    config = Params.from_file(args.config, ext_vars={'train_path': args.train, 'val_path': args.val_train})

    val_partition = args.val_train
    reader = DatasetReader.from_params(config.duplicate().pop('dataset_reader'))
    model = train_model(config, args.save, force=True)

    if args.val_finetune:
        val_partition = args.val_finetune
        if args.finetune:
            finetune_config = Params.from_file(args.config,
                                               ext_vars={'train_path': args.finetune, 'val_path': args.val_finetune})
            model = fine_tune_model(model, finetune_config, os.path.join(args.save, 'ft'), extend_vocab=True)

    predictor = Predictor(model, reader)
    correct, total = 0, 0
    for i in reader._read(val_partition):
        pred = predictor.predict_instance(i)
        gold_tags = i.fields['pos_tags'].labels
        pred_tags = pred['tags']

        assert len(gold_tags) == len(pred_tags)
        for (gold, pred) in zip(gold_tags, pred_tags):
            if gold == pred:
                correct += 1

            total += 1

    print("! val acc: {} / {} = {}".format(correct, total, correct / total))


main()
