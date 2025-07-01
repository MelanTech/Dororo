extends Node
class_name ConfigManager

const WINDOW_SEC_NAME: StringName = &"window"

@export var config_path:String = "res://config.ini"

var _config = ConfigFile.new()
var _sections: Dictionary[StringName, ConfigSection] = {}

func _ready() -> void:
	load_config()
	
func add_section(name: StringName) -> ConfigSection:
	_sections[name] = ConfigSection.new(name, self)
	return _sections[name]
	
func get_section(name: StringName) -> ConfigSection:
	return _sections.get(name)
	
func load_config():
	if not _config.load(config_path):
		save_config()
		
func save_config():
	return _config.save(config_path)
		
func set_value(section: String, key: String, value):
	_config.set_value(section, key, value)
	
func get_value(section: String, key: String, default=null):
	return _config.get_value(section, key, default)

func get_window_config(key: String, default=null):
	return get_value(WINDOW_SEC_NAME, key, default)

func on_window_config_change(key:String, value):
	_config.set_value(WINDOW_SEC_NAME, key, value)
	save_config()
