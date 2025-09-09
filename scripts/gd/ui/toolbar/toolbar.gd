extends NinePatchRect

@onready var config = get_node("/root/Config")

func _ready() -> void:
	$"../Chatbar/MarginContainer/HBoxContainer/BackButton".pressed.connect(on_chat_bar_back_button_pressed)
	$"Buttons/ChatButton".pressed.connect(on_chat_button_pressed)
	
func on_chat_button_pressed():
	$"../Chatbar".visible = true
	visible = false
	
func on_chat_bar_back_button_pressed():
	$"../Chatbar".visible = false
	visible = true

func _on_exit_button_pressed() -> void:
	get_tree().quit()

#func _on_other_app_fullscreen(is_fullscreen):
	#if is_fullscreen:
		#$Buttons/StickButton.set_pressed_no_signal(false)
	#else:
		#var state = config.get_common_config("stick")
		#$Buttons/StickButton.set_pressed_no_signal(state)
		#
	#get_tree().root.get_window().always_on_top = !is_fullscreen
	
