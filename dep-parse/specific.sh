#!/bin/bash
tb_short=(ar_padt eu_bdt zh_gsd en_ewt
          fi_tdt he_htb hi_hdtb it_isdt
          ja_gsd ko_gsd ru_syntagrus
          sv_talbanken tr_imst)
mods=(longest shortest)
size=(10 50 100 500 1000)

for m in ${mods[@]}; do
    for s in ${size[@]}; do
        for trg in ${tb_short[@]}; do
            x="${s}.${m}"
            exp="dep.${trg}.${x}"
            echo "sbatch -J ${exp} -e experiments/logs/ft_${s}/${x}.${trg} -o experiments/logs/ft_${s}/${x}.${trg} specific.slurm ${trg} ${x}"
        done
    done
done
