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

 	    nextflow run main.nf -profile docker --input {driver.genes.file} --participant_id {tool.name} --goldstandard_dir {gold.standards.dir} --cancer_types {analyzed.cancer.types}

	    Mandatory arguments:
                --input		List of cancer genes prediction
				--community_id			Name or OEB permanent ID for the benchmarking community
                --participant_id  		Name of the tool used for prediction
                --goldstandard_dir 		Dir that contains metrics reference datasets for all cancer types
                --challenges_ids  		List of types of cancer selected by the user, separated by spaces

	    Other options:
				--assessment_results	The output directory where the results from the computed metrics step will be saved
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
         tool name : ${params.participant_id}
         metrics reference datasets: ${params.goldstandard_dir}
		 selected cancer types: ${params.challenges_ids}
		 assessment results directory: ${params.assessment_results}
		 Statistics results about nextflow run: ${params.statsdir}
         """
	.stripIndent()

}


// input files

input_file = file(params.input)
tool_name = params.participant_id.replaceAll("\\s","_")
gold_standards_dir = Channel.fromPath(params.goldstandard_dir, type: 'dir' ) 
cancer_types = params.challenges_ids
community_id = params.community_id
EXIT_STAT = Channel.value(params.validation_status)

// output 
assessment_out = file(params.assessment_results)


process compute_metrics {

	tag "Computing benchmark metrics for submitted data"

	input:
	val file_validated from EXIT_STAT
	file input_file
	val cancer_types
	file gold_standards_dir
	val tool_name
	val community_id
	val assessment_out

	when:
	file_validated == 0

	output:
	val assessment_out into PARTICIPANT_DATA

	"""
	python /app/compute_metrics.py -i $input_file -c $cancer_types -m $gold_standards_dir -p $tool_name -com $community_id -o $assessment_out
	"""

}

workflow.onComplete { 
	println ( workflow.success ? "Done!" : "Oops .. something went wrong" )
}
