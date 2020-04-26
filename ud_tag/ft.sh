#!/bin/bash
tb_short=(ar_padt eu_bdt zh_gsd en_ewt 
          fi_tdt he_htb hi_hdtb it_isdt
          ja_gsd ko_gsd ru_syntagrus
          sv_talbanken tr_imst)

for trg in ${tb_short[@]}; do
    sbatch -J tag.${trg} -e experiments/logs/ft_0/${trg} -o experiments/logs/ft_0/${trg} ft.slurm ${trg}
done

