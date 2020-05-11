local COMMON = import 'common_cpu.jsonnet';

{
    "dataset_reader": COMMON["dataset_reader"],
    "train_data_path": std.extVar("train_path"),
    "validation_data_path": std.extVar("val_path"),
    "model": {
      "type": "from_archive",
      "archive_file": std.extVar("model_path"),
    },
    "data_loader": COMMON["data_loader"],
    "trainer": COMMON["trainer"],
  }
