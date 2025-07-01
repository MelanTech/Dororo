class_name BaseBindingSource

var _source_object
var _property_list: Array[Dictionary]

var _target_dict = {}


func _init(source_object = self, source_value_change_notify_signal = null):
	assert(source_object != null, "The source object must not be null.")
	assert(
		source_object is not Object or source_object != self or BaseBindingSource != get_script(),
		"The source object must be passed unless the class inherits BindingSource."
	)
	assert(
		source_object is not Object or source_object != self,
		"Currently, initialize by self is not supported."
	)

	_source_object = source_object

	if source_object is Object:
		_property_list = source_object.get_property_list()

	elif source_object is Dictionary:
		_property_list = _get_dict_property_list(source_object)

	else:
		push_error("The source object must be an object or a dict.")

	var signal_instance = _get_signal(source_object, source_value_change_notify_signal)
	if signal_instance is Signal:
		signal_instance.connect(_on_source_value_change_notified)


func _get_property_list():
	return _property_list


func _get(property):
	if property in _source_object:
		return _source_object[property]

	return null


func _set(property, value):
	_source_object[property] = value
	_update_target(property, value)
	return true


func bind_to(
	source_property: StringName,
	target_object,
	target_property: StringName,
	converter_pipeline: BindingConverterPipeline = null,
	target_value_change_signal = null,
	with_pipeline: BindingWithPipeline = null,
):
	var binding_dict = _target_dict.get_or_add(source_property, {}) as Dictionary
	var binding_key = _get_binding_key(target_object, target_property)

	assert(
		not binding_dict.has(binding_key),
		(
			"The source property %s has already been bound to the target property %s."
			% [source_property, target_property]
		)
	)

	var binding = BindingWithTargetSignal.new(
		self,
		source_property,
		target_object,
		target_property,
		converter_pipeline,
		_get_signal(target_object, target_value_change_signal),
		with_pipeline
	)
	binding_dict[binding_key] = binding


func unbind_from(source_property: StringName, target_object, target_property: StringName):
	assert(
		_target_dict.has(source_property),
		"The source property %s has not been bound to any target properties." % source_property
	)

	var binding_dict = _target_dict.get(source_property) as Dictionary
	var binding_key = _get_binding_key(target_object, target_property)

	assert(
		binding_dict.has(binding_key),
		(
			"The source property %s has not been bound to the target property %s."
			% [source_property, target_property]
		)
	)

	binding_dict.erase(binding_key)


func _on_source_value_change_notified(source_property: StringName):
	var source_value = _source_object[source_property]
	_update_target(source_property, source_value)


func _update_target(source_property: StringName, source_value: Variant):
	var binding_dict_or_null = _target_dict.get(source_property)
	if binding_dict_or_null == null:
		return

	var binding_dict = binding_dict_or_null as Dictionary

	for binding_key in binding_dict.keys():
		var binding = binding_dict[binding_key] as Binding
		if binding.is_valid:
			binding.pass_source_value(source_value)
		else:
			binding_dict.erase(binding_key)


static func _get_dict_property_list(dict: Dictionary):
	var property_list: Array[Dictionary] = []

	for key in dict:
		var value = dict[key]
		var type = typeof(value)

		var property = {
			"name": key,
			"type": type,
			"class_name": value.get_class() if type == TYPE_OBJECT else "",
		}
		property_list.append(property)

	return property_list


static func _get_signal(object, signal_ref):
	if signal_ref == null:
		return null

	if signal_ref is String or signal_ref is StringName:
		assert(
			object.has_signal(signal_ref),
			"The signal name must refer to an existing signal of the specified object."
		)
		return Signal(object, signal_ref)

	if signal_ref is Signal:
		return signal_ref

	push_error("The arg signal_ref must be null, String, StringName, or Signal.")


static func _get_binding_key(target_object, target_property: StringName):
	if target_object is Object:
		return "%s.%s" % [target_object.get_instance_id(), target_property]

	if target_object is Dictionary:
		var id = target_object.get_or_add("__BINDING_ID__", UUID.v7())
		return "%s.%s" % [id, target_property]

	push_error("The target object must be an object or a dict.")


class BindingWithTargetSignal:
	extends Binding

	func _init(
		source_object,
		source_property: StringName,
		target_object,
		target_property: StringName,
		converter_pipeline: BindingConverterPipeline,
		target_value_change_signal,
		with_pipeline: BindingWithPipeline = null,
	):
		super(source_object, source_property, target_object, target_property, converter_pipeline, with_pipeline)

		var source_value = source_object[source_property]
		pass_source_value(source_value)

		if target_value_change_signal is Signal:
			target_value_change_signal.connect(_on_target_value_changed)

	func _on_target_value_changed(target_value: Variant):
		pass_target_value(target_value)
