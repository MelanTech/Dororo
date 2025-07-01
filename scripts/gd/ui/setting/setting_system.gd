extends Node

@onready var _config: ConfigManager = get_node("/root/Config")
@onready var _auto_starter = get_node("/root/AutoStarter")
var _section: ConfigSection 
var _app_name = ProjectSettings.get_setting("application/config/name")

func _ready() -> void:
	_section = _config.add_section(&"system")
	
	_bind_components()
	_config.save_config()
	_section.load_props()
	_load_config()

func _bind_components():
	_section.set_prop(&"auto_start", false)
	_section.bind(&"auto_start").with(_update_auto_start).to_check_box($AutoStartCheckbox)
	
	_section.set_prop(&"power_save", true)
	_section.bind(&"power_save").with(_update_power_save).to_check_box($PowerSaveCheckbox)
	
	_section.set_prop(&"auto_hide", false)
	_section.bind(&"auto_hide").with(_update_auto_hide).to_check_box($AutoHideCheckbox)
	
func _load_config():
	$AutoStartCheckbox.set_pressed_no_signal(_auto_starter.IsAutoStartEnabled(_app_name))
	$PowerSaveCheckbox.set_pressed_no_signal(_section.get_prop(&"power_save"))
	OS.set_low_processor_usage_mode(_section.get_prop(&"power_save"))
	$AutoHideCheckbox.set_pressed_no_signal(_section.get_prop(&"auto_hide"))
	get_node("/root/Node2D").set_fullscreen_status(_section.get_prop(&"auto_hide"))
	
func _update_auto_start(name, value):
	if value:
		_auto_starter.EnableAutoStart(_app_name)
	else:
		_auto_starter.DisableAutoStart(_app_name)
		
func _update_power_save(name, value):
	OS.set_low_processor_usage_mode(value)
		
func _update_auto_hide(name, value):
	get_node("/root/Node2D").set_fullscreen_status(_section.get_prop(&"auto_hide"))
