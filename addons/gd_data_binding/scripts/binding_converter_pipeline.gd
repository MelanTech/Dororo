class_name BindingConverterPipeline

var _source_to_target_funcs: Array[Callable] = []
var _target_to_source_funcs: Array[Callable] = []

var _converters: Array[BindingConverter] = []


func _init(
	source_to_target_funcs: Array[Callable] = [], target_to_source_funcs: Array[Callable] = []
):
	_source_to_target_funcs = source_to_target_funcs
	_target_to_source_funcs = target_to_source_funcs


func copy():
	var converter_pipeline = BindingConverterPipeline.new(
		_source_to_target_funcs.duplicate(), _target_to_source_funcs.duplicate()
	)
	converter_pipeline._converters = _converters.duplicate()
	return converter_pipeline


func append(converter):
	if converter is BindingConverter:
		_source_to_target_funcs.push_back(converter.source_to_target)
		_target_to_source_funcs.push_front(converter.target_to_source)

		_converters.append(converter)

	elif converter is Callable:
		_source_to_target_funcs.push_back(converter)

	elif converter is Array:
		_source_to_target_funcs.push_back(converter[0])
		_target_to_source_funcs.push_front(converter[1])

	else:
		push_error("The arg converter must be BindingConverter, Callable, or [Callable, Callable].")
		breakpoint


func source_to_target(source_value: Variant) -> Variant:
	var converted_value = source_value

	for source_to_target_func in _source_to_target_funcs:
		converted_value = source_to_target_func.call(converted_value)

	return converted_value


func target_to_source(target_value: Variant) -> Variant:
	var converted_value = target_value

	for target_to_source_func in _target_to_source_funcs:
		converted_value = target_to_source_func.call(converted_value)

	return converted_value
