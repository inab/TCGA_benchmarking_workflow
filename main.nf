#!/usr/bin/env nextflow

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

 	    nextflow run main.nf -profile docker --input {driver.genes.file} --public_ref_dir {validation.reference.file} --participant_id {tool.name} --cancer_types {analyzed.cancer.types} 
	    Mandatory arguments:
                --input		List of cancer genes prediction
				--community_id			Name or OEB permanent ID for the benchmarking community
                --public_ref_dir 		Directory with list of cancer genes used to validate the predictions
                --participant_id  		Name of the tool used for prediction
                --challenges_ids  		List of types of cancer selected by the user, separated by spaces
                --assess_dir			Dir where the data for the benchmark are stored

	    Other options:
                --validation_result		The output directory where the results from validation step will be saved
				--statsdir	The output directory with nextflow statistics
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
		 selected cancer types: ${params.challenges_ids}
		 validation results directory: ${params.validation_result}
		 Statistics results about nextflow run: ${params.statsdir}
         """
	.stripIndent()

}


// input files

input_file = file(params.input)
ref_dir = Channel.fromPath( params.public_ref_dir, type: 'dir' )
tool_name = params.participant_id.replaceAll("\\s","_")
cancer_types = params.challenges_ids
community_id = params.community_id

// output 
validation_out = file(params.validation_result)


process validation {

	// validExitStatus 0,1
	tag "Validating input file format"

	input:
	file input_file
	file ref_dir 
	val cancer_types
	val tool_name
	val community_id
	val validation_out

	output:
	val task.exitStatus into EXIT_STAT
	
	"""
	python /app/validation.py -i $input_file -r $ref_dir -com $community_id -c $cancer_types -p $tool_name -o $validation_out
	"""

}


workflow.onComplete { 
	println ( workflow.success ? "Done!" : "Oops .. something went wrong" )
}
