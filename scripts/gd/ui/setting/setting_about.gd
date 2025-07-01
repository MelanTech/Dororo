extends Node

@export var update_message_box: Resource

func _ready() -> void:
	var ver = "当前版本：%s" % ProjectSettings.get_setting("application/config/version")
	ver += "  引擎版本：%s" % Engine.get_version_info()["string"]
	$VersionContainer/VersionIndicator.set_text(ver)

func _on_check_update_button_pressed() -> void:
	var scene = ResourceLoader.load(update_message_box.get_path())
	scene = scene.instantiate()
	if not find_child(scene.get_name()):
		add_child(scene)
