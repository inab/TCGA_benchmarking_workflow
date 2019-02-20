# OpenEBench data submission workflow with Nextflow

Example pipeline with Nextflow used to submit TCGA data to the OpenEBench [Virtual Research Environment (VRE)](https://openebench.bsc.es/submission/workspace/).

## DESCRIPTION

The workflow takes an input file with Cancer Driver Genes predictions and performs a benchmark against the data currently stored in OpenEBench within the TCGA community, providing two assessment metrics for that predicitions and some plots that allow to visualize the performance of the tool. The workflow consists in three standard steps, defined by OpenEBench, which are run in separated [Docker containers](https://github.com/inab/TCGA_visualizer):
1. **Validation**: the input file format is checked and, if required, the content of the file is validated (e.g check whether the submitted gene IDs exist)
2. **Metrics Computation**: the predictions are compared with the 'Gold Standards' provided by the community, which results in two performance metrics - precision (Positive Predictive Value) and recall(True Positive Rate).
3. **Results Consolidation**: the benchmark itself is performed by merging the tool metrics with the rest of TCGA data. The results are provided in JSON format and SVG format (scatter plot).

![workflow](workflow.jpg)


## DATA

* [TCGA_sample_data](https://github.com/javi-gv94/TCGA_nf_workflow/tree/master/TCGA_sample_data) folder contains all the data required to run the workflow. It is derived from the manuscript:
[Comprehensive Characterization of Cancer Driver Genes and Mutations](https://www.cell.com/cell/fulltext/S0092-8674%2818%2930237-X?code=cell-site), Bailey et al, 2018, Cell

[![doi:10.1016/j.cell.2018.02.060](https://img.shields.io/badge/doi-10.1016%2Fj.cell.2018.02.060-green.svg)](https://doi.org/10.1016/j.cell.2018.02.060) 
* [sample_out](https://github.com/javi-gv94/TCGA_nf_workflow/tree/master/sample_out) folder contains an example output for a worklow run, with two cancer types / challenges selected (ACC, BRCA)


## USAGE
In order to use the workflow you need to:
* Install [Nextflow](https://www.nextflow.io/)
* Build locally the three Docker images found in [this repository](https://github.com/inab/TCGA_visualizer), with the build.sh script
* Run it just using *'nextflow run main.nf'*

Default input parameters can be specified in the [config](https://github.com/javi-gv94/TCGA_nf_workflow/blob/master/nextflow.config) file