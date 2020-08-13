process compute_metrics {

	tag "Computing benchmark metrics for submitted data"

	input:
	val file_validated
	path input_file
	val cancer_types
	path gold_standards_dir
	val tool_name
	val community_id
	val assessment_out

	when:
	file_validated == 0

	output:
	val assessment_out, emit: assessment_datasets

	"""
	python /app/compute_metrics.py -i $input_file -c $cancer_types -m $gold_standards_dir -p $tool_name -com $community_id -o $assessment_out
	"""

}
