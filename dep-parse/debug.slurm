#!/bin/bash
#SBATCH --account=nn9447k
#SBATCH --partition=accel
#SBATCH --gres=gpu:1
#SBATCH --time=100:00:00
#SBATCH --mem-per-cpu=16G

set -o errexit
source ~/.bashrc
conda activate debug

export UD="$HOME/corpora/ud"
python3 runner.py --train "$UD/en_ewt/en_ewt-ud-train.conllu" --val_train "$UD/en_ewt/en_ewt-ud-dev.conllu" \
                --finetune "$UD/sv_talbanken/sorted/10.longest.conllu" --val_finetune "$UD/sv_talbanken/sv_talbanken-ud-dev.conllu" \
                --config "configs/gpu" --save "experiments/models/debug" --model "xlmr"
