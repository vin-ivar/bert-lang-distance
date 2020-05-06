#!/bin/bash
#SBATCH --account=nn9447k
#SBATCH --partition=accel
#SBATCH --gres=gpu:1
#SBATCH --time=100:00:00
#SBATCH --mem-per-cpu=10G

set -o errexit
source ~/.bashrc
conda activate nlp

export PANX="$HOME/corpora/panx_dataset"
python3 runner.py --train "$PANX/en/train" --val_train "$PANX/en/dev" --finetune "$PANX/$1/sorted/$2" --val_finetune "$PANX/$1/dev" --config "./configs/gpu_xlm.jsonnet" --save "experiments/models/$1.$2"
