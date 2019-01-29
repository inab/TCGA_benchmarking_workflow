#!/bin/bash -ue
mkdir out
python /app/compute_metrics.py -i All_Together.txt -c ACC BRCA -m metrics_ref_datasets -p my_gene_predictor -o /home/jgarrayo/nextflow_tutorial/TCGA_nextflow/out
