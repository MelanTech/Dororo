extends Node

@onready var _config: ConfigManager = get_node("/root/Config")
@onready var _auto_starter = get_node("/root/AutoStarter")
var _section: ConfigSection 
var _app_name = ProjectSettings.get_setting("application/config/name")

func _ready() -> void:
	_section = _config.add_section(&"interact")
	
	_bind_components()
	_config.save_config()
	_section.load_props()
	_load_config()

func _bind_components():
	_section.set_prop(&"pin", false)
	_section.bind(&"pin").with(_update_pin).to_check_box($PinCheckbox)
	_section.bind(&"pin").with(_update_pin).to_toggle_button(get_node("/root/Node2D/GUI/Toolbar/Buttons/StickButton"))
	
	_section.set_prop(&"stroll", false)
	_section.bind(&"stroll").with(_update_stroll).to_check_box($StrollCheckbox)
	_section.bind(&"stroll").with(_update_stroll).to_check_box(get_node("/root/Node2D/GUI/Toolbar/Buttons/InteractButton/InteractMenu/VBoxContainer/StrollCheckbox"))
	
	_section.set_prop(&"mouse_follow", false)
	_section.bind(&"mouse_follow").with(_update_mouse_follow).to_check_box($MouseFollowCheckbox)
	_section.bind(&"mouse_follow").with(_update_mouse_follow).to_toggle_button(get_node("/root/Node2D/GUI/Toolbar/Buttons/InteractButton/InteractMenu/VBoxContainer/MouseFollowCheckbox"))
	
	_section.set_prop(&"dock", false)
	_section.bind(&"dock").with(_update_dock).to_check_box($Dock/DockCheckbox)
	_section.bind(&"dock").using(InvertBoolBindingConverter.new()).to($Dock/OptionButton, &"disabled")
	
	_section.set_prop(&"dock_type", 0)
	_section.bind(&"dock_type").with(_update_dock_type).to_option_button($Dock/OptionButton)
	
	_section.set_prop(&"drop_remove", true)
	_section.bind(&"drop_remove").with(_update_drop_remove).to_check_box($DropRemoveCheckBox)
	
func _load_config():
	$PinCheckbox.set_pressed_no_signal(_section.get_prop(&"pin"))
	get_node("/root/Node2D/GUI/Toolbar/Buttons/StickButton").set_pressed_no_signal(_section.get_prop(&"pin"))
	get_tree().root.get_window().always_on_top = _section.get_prop(&"pin")
	
	$StrollCheckbox.set_pressed_no_signal(_section.get_prop(&"stroll"))
	get_node("/root/Node2D/GUI/Toolbar/Buttons/InteractButton/InteractMenu/VBoxContainer/StrollCheckbox").set_pressed_no_signal(_section.get_prop(&"stroll"))
	get_node("/root/Node2D/GDCubismUserModel/Animation/EffectMove/EffectRandMove").enable = _section.get_prop(&"stroll")
	
	$MouseFollowCheckbox.set_pressed_no_signal(_section.get_prop(&"mouse_follow"))
	get_node("/root/Node2D/GUI/Toolbar/Buttons/InteractButton/InteractMenu/VBoxContainer/MouseFollowCheckbox").set_pressed_no_signal(_section.get_prop(&"mouse_follow"))
	get_node("/root/Node2D/GDCubismUserModel/Animation/EffectMouseFollow").enable = _section.get_prop(&"mouse_follow")
	
	$Dock/DockCheckbox.set_pressed_no_signal(_section.get_prop(&"dock"))
	get_node("/root/Node2D").enable_docking = _section.get_prop(&"dock")
	$Dock/OptionButton.select(_section.get_prop(&"dock_type"))
	$Dock/OptionButton.set_disabled(not get_node("/root/Node2D").enable_docking)
	get_node("/root/Node2D").dock_to_taskbar = _section.get_prop(&"dock_type")
	
	$DropRemoveCheckBox.set_pressed_no_signal(_section.get_prop(&"drop_remove"))
	get_node("/root/Node2D/GDCubismUserModel/DropRemover").enable = _section.get_prop(&"drop_remove")
	
func _update_pin(name, value):
	get_tree().root.get_window().always_on_top = value
	
func _update_stroll(name, value):
	get_node("/root/Node2D/GDCubismUserModel/Animation/EffectMove/EffectRandMove").enable = value
	
func _update_mouse_follow(name, value):
	get_node("/root/Node2D/GDCubismUserModel/Animation/EffectMouseFollow").enable = value
	
func _update_dock(name, value):
	get_node("/root/Node2D").enable_docking = value
	
func _update_dock_type(name, value):
	get_node("/root/Node2D").dock_to_taskbar = value
	
func _update_drop_remove(name, value):
	get_node("/root/Node2D/GDCubismUserModel/DropRemover").enable = value
	
