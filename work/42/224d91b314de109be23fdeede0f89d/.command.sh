#!/bin/bash -ue
docker run -i -v /home/jgarrayo/nextflow_tutorial/TCGA_nextflow:/home/jgarrayo/nextflow_tutorial/TCGA_nextflow -v "$PWD":"$PWD" -w "$PWD" --name $NXF_BOXID tcga_validation:latest -i All_Together.txt -r public_ref
