extends Node
class_name ConfigSection

var _binder: BindingSource
var _config_manager: ConfigManager

var _section_name: StringName
var _prop_dict: Dictionary = {}

func _init(section_name, config_manager: ConfigManager) -> void:
	_section_name = section_name
	_config_manager = config_manager
	_binder = BindingSource.new(_prop_dict)
	
func bind(name: StringName):
	return _binder.bind(name).with(_update_prop)
	
func set_prop(name: StringName, value: Variant):
	_prop_dict[name] = value
	
func get_prop(name: StringName):
	return _prop_dict.get(name)
	
func load_props():
	for key in _prop_dict:
		var value = _config_manager.get_value(_section_name, key)
		if value != null:
			_prop_dict.set(key, value)

func _update_prop(name, value):
	_config_manager.set_value(_section_name, name, value)
	_config_manager.save_config()
