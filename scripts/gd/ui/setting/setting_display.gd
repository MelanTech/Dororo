extends Node

const MSAA_LEVEL = {0: Viewport.MSAA_2X, 1: Viewport.MSAA_4X, 2: Viewport.MSAA_8X}

@onready var _config: ConfigManager = get_node("/root/Config")
var _section: ConfigSection 

func _ready() -> void:
	_section = _config.add_section(&"display")
	
	_bind_components()
	_config.save_config()
	_section.load_props()
	_load_config()

func _bind_components():
	_section.set_prop(&"fps_limit", true)
	_section.bind(&"fps_limit").with(_update_fps_limit).to_check_box($MaxFPSContainer/MaxFPSCheckbox)
	_section.bind(&"fps_limit").to($MaxFPSContainer/HSlider, &"editable")
	
	_section.set_prop(&"max_fps", 30.)
	_section.bind(&"max_fps").with(_update_max_fps).to_slider($MaxFPSContainer/HSlider)
	_section.bind(&"max_fps").using(_get_fps_label).to_label($MaxFPSContainer/Indicator)
	
	_section.set_prop(&"vsync", false)
	_section.bind(&"vsync").with(_update_vsync).to_check_box($VsyncCheckbox)
	
	_section.set_prop(&"msaa", false)
	_section.bind(&"msaa").with(_update_vsync).to_check_box($MSAAContainer/MSAACheckBox)
	_section.bind(&"msaa").using(InvertBoolBindingConverter.new()).to($MSAAContainer/OptionButton, &"disabled")
	
	_section.set_prop(&"msaa_level", 0)
	_section.bind(&"msaa_level").with(_update_msaa_level).to_option_button($MSAAContainer/OptionButton)
	
func _load_config():
	$MaxFPSContainer/MaxFPSCheckbox.set_pressed_no_signal(_section.get_prop(&"fps_limit"))
	$MaxFPSContainer/HSlider.set_value_no_signal(_section.get_prop(&"max_fps"))
	$MaxFPSContainer/Indicator.set_text(_get_fps_label($MaxFPSContainer/HSlider.get_value()))
	$VsyncCheckbox.set_pressed_no_signal(_section.get_prop(&"vsync"))
	$MSAAContainer/MSAACheckBox.set_pressed(_section.get_prop(&"msaa"))
	$MSAAContainer/OptionButton.select(_section.get_prop(&"msaa_level"))
	$MSAAContainer/OptionButton.disabled = not $MSAAContainer/MSAACheckBox.is_pressed()
	
func _update_fps_limit(name, value):
	if value:
		Engine.set_max_fps($MaxFPSContainer/HSlider.value)
	else:
		Engine.set_max_fps(0)
		
func _update_max_fps(name, value):
	Engine.set_max_fps($MaxFPSContainer/HSlider.value)
	
func _update_vsync(name, value):
	if value:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSyncMode.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSyncMode.VSYNC_DISABLED)
		
func _update_msaa(name, value):
	var viewport = get_tree().root.get_viewport()
	if value:
		viewport.msaa_2d = _get_msaa_level($MSAAContainer/OptionButton.get_selected_id())
	else:
		viewport.msaa_2d = Viewport.MSAA_DISABLED
		
func _update_msaa_level(name, value):
	get_tree().root.get_viewport().msaa_2d = _get_msaa_level($MSAAContainer/OptionButton.get_selected_id())

func _get_fps_label(value):
	return "%d FPS" % int(value)
	
func _get_msaa_level(value):
	return MSAA_LEVEL[value]
