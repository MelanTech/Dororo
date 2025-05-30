extends Node
class_name ConfigManager

const COMMON_SEC_NAME: String = "common"
const WINDOW_SEC_NAME: String = "window"

@export var config_path:String = "res://config.ini"

var _config = ConfigFile.new()

func _ready() -> void:
	load_config()
	
func load_config():
	if not _config.load(config_path):
		save_config()
		
func save_config():
	_config.save(config_path)
		
func set_value(section: String, key: String, value):
	_config.set_value(section, key, value)
	
func get_value(section: String, key: String, default=null):
	return _config.get_value(section, key, default)

func get_window_config(key: String, default=null):
	return get_value(WINDOW_SEC_NAME, key, default)

func on_window_config_change(key:String, value):
	_config.set_value(WINDOW_SEC_NAME, key, value)
	save_config()

func get_common_config(key: String, default=null):
	return get_value(COMMON_SEC_NAME, key, default)

func on_common_config_change(key:String, value):
	_config.set_value(COMMON_SEC_NAME, key, value)
	save_config()
