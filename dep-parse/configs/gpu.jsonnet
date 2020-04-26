{
    "dataset_reader": {
        "type":  "wordpiece_ud",
        "tokenizer": {
            "type": "pretrained_transformer",
            "model_name": "bert-base-multilingual-cased",
            "do_lowercase": false,
        },
        "token_indexers": {
            "tokens": {
                "type": "pretrained_transformer",
                "model_name": "bert-base-multilingual-cased",
                "do_lowercase": false,
            }
        }
    },
    "train_data_path": std.extVar("train_path"),
    "validation_data_path": std.extVar("val_path"),
    "model": {
      "type": "wordpiece_parser",
      "text_field_embedder": {
        "tokens": {
          "type": "bert-pretrained",
          "pretrained_model": "bert-base-multilingual-cased",
        }
      },
      "encoder": {
        "type": "stacked_bidirectional_lstm",
        "input_size": 768,
        "hidden_size": 400,
        "num_layers": 3,
        "recurrent_dropout_probability": 0.3,
        "use_highway": true
      },
      "use_mst_decoding_for_validation": false,
      "arc_representation_dim": 500,
      "tag_representation_dim": 100,
      "dropout": 0.3,
      "input_dropout": 0.3,
      "initializer": [
        [".*projection.*weight", {"type": "xavier_uniform"}],
        [".*projection.*bias", {"type": "zero"}],
        [".*tag_bilinear.*weight", {"type": "xavier_uniform"}],
        [".*tag_bilinear.*bias", {"type": "zero"}],
        [".*weight_ih.*", {"type": "xavier_uniform"}],
        [".*weight_hh.*", {"type": "orthogonal"}],
        [".*bias_ih.*", {"type": "zero"}],
        [".*bias_hh.*", {"type": "lstm_hidden_bias"}]]
    },

    "iterator": {
      "type": "bucket",
      "sorting_keys": [["words", "num_tokens"]],
      "batch_size" : 128
    },
    "trainer": {
      "num_epochs": 50,
      "grad_norm": 5.0,
      "patience": 50,
      "cuda_device": 0,
      "validation_metric": "+LAS",
      "optimizer": {
        "type": "dense_sparse_adam",
        "betas": [0.9, 0.9]
      }
    }
  }