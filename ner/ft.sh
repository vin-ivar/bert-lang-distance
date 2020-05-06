#!/bin/bash
tb_short=(ar eu zh en fi he hi it
          ja ko ru sv tr)

for trg in ${tb_short[@]}; do
    sbatch -J ner.${trg} -e experiments/logs/xlmr/ft_0/${trg} -o experiments/logs/xlmr/ft_0/${trg} ft.slurm ${trg}
done
