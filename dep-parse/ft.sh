#!/bin/bash
tb_short=(ar_padt eu_bdt zh_gsd en_ewt 
          fi_tdt he_htb hi_hdtb it_isdt
          ja_gsd ko_gsd ru_syntagrus
          sv_talbanken tr_imst)

for trg in ${tb_short[@]}; do
    sbatch -J dep.${trg} -e experiments/logs/xlmr/ft_0/${trg} -o experiments/logs/xlmr/ft_0/${trg} ft.slurm ${trg}
done

