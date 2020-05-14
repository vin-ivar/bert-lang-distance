#!/bin/bash
#SBATCH --account=nn9447k
#SBATCH --partition=accel
#SBATCH --gres=gpu:1
#SBATCH --time=100:00:00
#SBATCH --mem-per-cpu=10G

set -o errexit
source ~/.bashrc
module purge
conda activate debug

export UD="$HOME/corpora/ud"
python3 runner.py --train "$UD/en_ewt/en_ewt-ud-train.conllu" --val_train "$UD/en_ewt/en_ewt-ud-dev.conllu" --val_finetune "$UD/$1/$1-ud-dev.conllu" \
                  --config "./configs/gpu" --save "experiments/models/baseline.$2.$1" --model $2
