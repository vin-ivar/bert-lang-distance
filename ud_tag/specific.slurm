#!/bin/bash
#SBATCH --account=nn9447k
#SBATCH --partition=accel
#SBATCH --gres=gpu:1
#SBATCH --time=100:00:00
#SBATCH --mem-per-cpu=10G

set -o errexit
source ~/.bashrc
conda activate nlp

export UD="$HOME/corpora/ud"
python3 runner.py --train "$UD/en_ewt/en_ewt-ud-train.conllu" --val_train "$UD/en_ewt/en_ewt-ud-dev.conllu" --finetune "$UD/$1/sorted/$2.conllu" --val_finetune "$UD/$1/$1-ud-dev.conllu" --config "configs/gpu.jsonnet" --save "experiments/models/$1.$2"
