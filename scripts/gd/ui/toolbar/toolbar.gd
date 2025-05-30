extends NinePatchRect

@onready var config = get_node("/root/Config")

signal stick_changed
signal stroll_changed
signal follow_mouse_changed

func _ready() -> void:
	load_config()
	bind_signals()
	
func load_config():
	var stick = config.get_common_config("stick", $"../..".get_window().always_on_top)
	var stroll = config.get_common_config("stroll", $"../../GDCubismUserModel/Animation/EffectRandMove".enable)
	var mouse_follow = config.get_common_config("follow_mouse", $"../../GDCubismUserModel/Animation/EffectMouseFollow".enable)
	
	# Load config
	get_tree().root.get_window().always_on_top = stick
	$"../../GDCubismUserModel/Animation/EffectRandMove".enable = stroll
	$"../../GDCubismUserModel/Animation/EffectMouseFollow".enable = mouse_follow
	
	# Setup GUI
	$Buttons/StickButton.button_pressed = stick
	$Buttons/InteractButton/InteractMenu/VBoxContainer/StrollCheckbox.button_pressed = stroll
	$Buttons/InteractButton/InteractMenu/VBoxContainer/MouseFollowCheckbox.button_pressed = mouse_follow
	
func bind_signals():
	stick_changed.connect(config.on_common_config_change)
	stroll_changed.connect(config.on_common_config_change)
	follow_mouse_changed.connect(config.on_common_config_change)

func _on_stick_button_toggled(toggled_on: bool) -> void:
	get_tree().root.get_window().always_on_top = toggled_on
	stick_changed.emit("stick", toggled_on)
	
func _on_stroll_checkbox_toggled(toggled_on: bool) -> void:
	$"../../GDCubismUserModel/Animation/EffectRandMove".enable = toggled_on
	stroll_changed.emit("stroll", toggled_on)

func _on_mouse_follow_checkbox_toggled(toggled_on: bool) -> void:
	$"../../GDCubismUserModel/Animation/EffectMouseFollow".enable = toggled_on
	follow_mouse_changed.emit("follow_mouse", toggled_on)

func _on_exit_button_pressed() -> void:
	get_tree().quit()
