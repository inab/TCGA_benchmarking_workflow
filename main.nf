#!/usr/bin/env nextflow

if (params.help) {
	
	    log.info"""
	    ==============================================
	    TCGA CANCER DRIVER GENES BENCHMARKING PIPELINE 
	    ==============================================
	    Usage:
	    Run the pipeline with default parameters:
	    nextflow run main.nf

	    Run with user parameters:
 	    nextflow run main.nf --predictionsFile {driver.genes.file} --public_ref_dir {validation.reference.file} --participant_name {tool.name} --metrics_ref_dir {gold.standards.dir} --cancer_types {analyzed.cancer.types} --assess_dir {benchmark.data.dir} --results_dir {output.dir}

	    Mandatory arguments:
                --predictionsFile		List of cancer genes prediction
                --public_ref_dir 		Directory with list of cancer genes used to validate the predictions
                --participant_name  		Name of the tool used for prediction
                --metrics_ref_dir 		Dir that contains metrics reference datasets for all cancer types
                --cancer_types  		List of types of cancer selected by the user, separated by spaces
                --assess_dir			Dir where the data for the benchmark are stored
	    Other options:
                --results_dir		The output directory where the results will be saved
	    Flags:
                --help			Display this message
	    """.stripIndent()

	exit 1
} else {

	log.info """\
		 ==============================================
	     TCGA CANCER DRIVER GENES BENCHMARKING PIPELINE 
	     ==============================================
         input file: ${params.predictionsFile}
         public reference directory : ${params.public_ref_dir}
         tool name : ${params.participant_name}
         metrics reference datasets: ${params.metrics_ref_dir}
		 selected cancer types: ${params.cancer_types}
		 benchmark data: ${params.assess_dir}
		 results directory: ${params.results_dir}
         """
	.stripIndent()

}


// input files

input_file = file(params.predictionsFile)
ref_dir = Channel.fromPath( params.public_ref_dir, type: 'dir' )
tool_name = params.participant_name
gold_standards_dir = Channel.fromPath(params.metrics_ref_dir, type: 'dir' ) 
cancer_types = params.cancer_types
benchmark_data = Channel.fromPath(params.assess_dir, type: 'dir' )

// output 

result = file(params.results_dir)

process validation {

	// validExitStatus 0,1
	tag "Validating input file format"

	input:
	file input_file
	file ref_dir 

	output:
	val task.exitStatus into EXIT_STAT
	
	"""
	python /app/validation.py -i $input_file -r $ref_dir
	"""

}

process compute_metrics {

	tag "Computing benchmark metrics for submitted data"

	input:
	val file_validated from EXIT_STAT
	file input_file
	val cancer_types
	file gold_standards_dir
	val tool_name
	val result

	when:
	file_validated == 0

	output:
	val result into PARTICIPANT_DATA

	"""
	python /app/compute_metrics.py -i $input_file -c $cancer_types -m $gold_standards_dir -p $tool_name -o $result
	"""

}

process manage_assessment_data {

	tag "Performing benchmark assessment and building plots"

	input:
	file benchmark_data
	file output from PARTICIPANT_DATA

	"""
	python /app/manage_assessment_data.py -b $benchmark_data -p $output -o $output
	"""

}


workflow.onComplete { 
	println ( workflow.success ? "Done!" : "Oops .. something went wrong" )
}
