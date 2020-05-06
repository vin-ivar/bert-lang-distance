#!/bin/bash
tb_short=(ar eu zh en fi he hi it
    ja ko ru sv tr)
mods=(random)
size=(10 50 100 500 1000)

for m in ${mods[@]}; do
    for s in ${size[@]}; do
        for trg in ${tb_short[@]}; do
            x="${s}.${m}"
            exp="ner.${trg}.${x}"
            echo "sbatch -J ${exp} -e experiments/logs/xlmr/ft_${s}/${x}.${trg} -o experiments/logs/xlmr/ft_${s}/${x}.${trg} specific.slurm ${trg} ${x}"
        done
    done
done
