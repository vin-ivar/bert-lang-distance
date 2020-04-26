{
    "dataset_reader":{
        "type":  "wordpiece_ud",
        "tokenizer": {
            "type": "pretrained_transformer",
            "model_name": "xlm-roberta-base",
            "do_lowercase": false,
        },
        "token_indexers": {
            "tokens": {
                "type": "pretrained_transformer",
                "model_name": "xlm-roberta-base",
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
          "type": "pretrained_transformer",
          "model_name": "xlm-roberta-base",
        }
      },
      "encoder": {
        "type": "stacked_bidirectional_lstm",
        "input_size": 768,
        "hidden_size": 4,
        "num_layers": 1,
        "recurrent_dropout_probability": 0.3,
        "use_highway": true
      },
      "use_mst_decoding_for_validation": false,
      "arc_representation_dim": 5,
      "tag_representation_dim": 2,
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
        [".*bias_hh.*", {"type": "lstm_hidden_bias"}],
      ]
    },

    "iterator": {
      "type": "bucket",
      "sorting_keys": [["words", "num_tokens"]],
      "batch_size" : 128
    },
    "trainer": {
      "num_epochs": 1,
      "grad_norm": 5.0,
      "cuda_device": -1,
      "validation_metric": "+LAS",
      "optimizer": {
        "type": "dense_sparse_adam",
        "betas": [0.9, 0.9]
      }
    }
  }