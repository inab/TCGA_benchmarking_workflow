process benchmark_consolidation {

	tag "Performing benchmark assessment and building plots"

	input:
	path benchmark_data
	val participant_metrics
	val aggregation_dir
	val validation_out
	val data_model_export_path

	"""
	python /app/manage_assessment_data.py -b $benchmark_data -p $participant_metrics -o $aggregation_dir
	python /app/merge_data_model_files.py -p $validation_out -m $participant_metrics -a $aggregation_dir -o $data_model_export_path
	"""

}
