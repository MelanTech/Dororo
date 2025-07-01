class_name Binding

var is_valid: bool:
	get:
		return _source_validator.call(_source_object) and _target_validator.call(_target_object)

var _source_object
var _source_property: StringName
var _source_validator: Callable

var _target_object
var _target_property: StringName
var _target_validator: Callable

var _converter_pipeline: BindingConverterPipeline
var _with_pipeline: BindingWithPipeline


func _init(
	source_object,
	source_property: StringName,
	target_object,
	target_property: StringName,
	converter_pipeline: BindingConverterPipeline = null,
	with_pipeline: BindingWithPipeline = null,
):
	assert(
		source_object is Object or source_object is Dictionary,
		"The source object must be an object or a dict."
	)
	assert(source_object != null, "The source object must not be null.")
	assert(
		source_property in source_object,
		"The source property %s was not in the source object." % source_property
	)

	assert(
		target_object is Object or target_object is Dictionary,
		"The target object must be an object or a dict."
	)
	assert(target_object != null, "The target object must not be null.")
	assert(
		target_property in target_object,
		"The target property %s was not in the target object." % target_property
	)

	_source_object = source_object
	_source_property = source_property
	_source_validator = _get_validator(source_object)

	_target_object = target_object
	_target_property = target_property
	_target_validator = _get_validator(target_object)

	if converter_pipeline == null:
		_converter_pipeline = BindingConverterPipeline.new()
	else:
		_converter_pipeline = converter_pipeline
		
	_with_pipeline = with_pipeline

func pass_source_value(source_value: Variant):
	var prev_target_value = _target_object[_target_property]
	var next_target_value = _converter_pipeline.source_to_target(source_value)
	if prev_target_value == next_target_value:
		return

	_target_object[_target_property] = next_target_value


func pass_target_value(target_value: Variant):
	var prev_source_value = _source_object[_source_property]
	var next_source_value = _converter_pipeline.target_to_source(target_value)
	if prev_source_value == next_source_value:
		return

	_source_object[_source_property] = next_source_value
	
	for with_func in _with_pipeline.get_pipeline():
		assert(with_func.is_valid(), "The with function must be a valid Callable.")
		with_func.call(_source_property, next_source_value)
			


static func _get_validator(object) -> Callable:
	if object is Object:
		return is_instance_valid

	return _none_object_validator


static func _none_object_validator(_p) -> bool:
	return true
