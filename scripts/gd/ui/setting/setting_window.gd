extends Window

func _ready() -> void:
	$"../Toolbar/Buttons/SettingButton".toggled.connect(_on_setting_button_toggled)
	$"./NinePatchRect/VBoxContainer/TitleBar/MarginContainer/HBoxContainer/CloseButton".pressed.connect(_on_close_button_pressed)

func _on_setting_button_toggled(toggled_on: bool):
	visible = toggled_on

func _on_close_button_pressed():
	visible = false
	$"../Toolbar/Buttons/SettingButton".set_pressed(false)
