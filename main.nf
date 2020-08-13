#!/usr/bin/env nextflow

nextflow.preview.dsl=2
include {validation} from './validation'
include {compute_metrics} from './compute_metrics'
include {benchmark_consolidation} from './consolidate_benchmark'

if (params.help) {
	
	    log.info"""
	    ==============================================
	    TCGA CANCER DRIVER GENES BENCHMARKING PIPELINE 
		Author: Javier Garrayo Ventas
		Barcelona Suercomputing Center. Spain. 2019
	    ==============================================
	    Usage:
	    Run the pipeline with default parameters:
	    nextflow run main.nf -profile docker

	    Run with user parameters:

 	    nextflow run main.nf -profile docker --input {driver.genes.file} --public_ref_dir {validation.reference.file} --participant_id {tool.name} --goldstandard_dir {gold.standards.dir} --cancer_types {analyzed.cancer.types} --assess_dir {benchmark.data.dir} --results_dir {output.dir}

	    Mandatory arguments:
                --input		List of cancer genes prediction
				--community_id			Name or OEB permanent ID for the benchmarking community
                --public_ref_dir 		Directory with list of cancer genes used to validate the predictions
                --participant_id  		Name of the tool used for prediction
                --goldstandard_dir 		Dir that contains metrics reference datasets for all cancer types
                --challenges_ids  		List of types of cancer selected by the user, separated by spaces
                --assess_dir			Dir where the data for the benchmark are stored

	    Other options:
                --validation_result		The output directory where the results from validation step will be saved
				--assessment_results	The output directory where the results from the computed metrics step will be saved
				--outdir	The output directory where the consolidation of the benchmark will be saved
				--statsdir	The output directory with nextflow statistics
				--data_model_export_path	The output dir where json file with benchmarking data model contents will be saved
	  			--otherdir					The output directory where custom results will be saved (no directory inside)
	    Flags:
                --help			Display this message
	    """.stripIndent()

	exit 1
} else {

	log.info """\
		 ==============================================
	     TCGA CANCER DRIVER GENES BENCHMARKING PIPELINE 
	     ==============================================
         input file: ${params.input}
		 benchmarking community = ${params.community_id}
         public reference directory : ${params.public_ref_dir}
         tool name : ${params.participant_id}
         metrics reference datasets: ${params.goldstandard_dir}
		 selected cancer types: ${params.challenges_ids}
		 benchmark data: ${params.assess_dir}
		 validation results directory: ${params.validation_result}
		 assessment results directory: ${params.assessment_results}
		 consolidated benchmark results directory: ${params.outdir}
		 Statistics results about nextflow run: ${params.statsdir}
		 Benchmarking data model file location: ${params.data_model_export_path}
		 Directory with community-specific results: ${params.otherdir}
         """
	.stripIndent()

}


// input files

input_file = file(params.input)
ref_dir = Channel.fromPath( params.public_ref_dir, type: 'dir' )
tool_name = params.participant_id.replaceAll("\\s","_")
gold_standards_dir = Channel.fromPath(params.goldstandard_dir, type: 'dir' ) 
cancer_types = params.challenges_ids
benchmark_data = Channel.fromPath(params.assess_dir, type: 'dir' )
community_id = params.community_id

// output 
validation_out = file(params.validation_result)
assessment_out = file(params.assessment_results)
aggregation_dir = file(params.outdir)
data_model_export_path = file(params.data_model_export_path)
other_dir = file(params.otherdir)

workflow{

	validation(input_file, ref_dir, cancer_types, tool_name, community_id, validation_out)
	compute_metrics(validation.out.validation_status, input_file, cancer_types, gold_standards_dir, tool_name, community_id, assessment_out)
	benchmark_consolidation( benchmark_data, compute_metrics.out.assessment_datasets, aggregation_dir, validation.out.validation_json, data_model_export_path)
	
}

workflow.onComplete { 
	println ( workflow.success ? "Done!" : "Oops .. something went wrong" )
}
