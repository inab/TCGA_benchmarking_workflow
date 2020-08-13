process validation {

	// validExitStatus 0,1
	tag "Validating input file format"

	input:
	path input_file
	path ref_dir 
	val cancer_types
	val tool_name
	val community_id
	val validation_out

	output:
	val task.exitStatus, emit: validation_status
	val validation_out, emit: validation_json

	"""
	python /app/validation.py -i $input_file -r $ref_dir -com $community_id -c $cancer_types -p $tool_name -o $validation_out
	"""

}
