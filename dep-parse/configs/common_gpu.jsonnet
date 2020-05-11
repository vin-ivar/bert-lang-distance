{
    "dataset_reader": {
        "type":  "wordpiece_ud",
        "tokenizer": {
            "type": "pretrained_transformer",
            "model_name": std.extVar("model_name"),
        },
        "token_indexers": {
            "tokens": {
                "type": "pretrained_transformer",
                "model_name": std.extVar("model_name"),
            }
        }
    },
    "data_loader": {
      "batch_sampler": {
        "type": "bucket",
        "sorting_keys": ["words"],
        "batch_size" : 32
      },
    },
    "trainer": {
      "num_epochs": 20,
      "grad_norm": 5.0,
      "patience": 20,
      "cuda_device": 0,
      "validation_metric": "+LAS",
      "optimizer": {
        "type": "dense_sparse_adam",
        "betas": [0.9, 0.9]
      }
    }
  }
