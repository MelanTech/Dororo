extends Node

const API_URL = &"https://api.github.com/repos/MelanTech/Dororo/tags"
const GITHUB_DOWNLOAD_URL = &"https://github.com/MelanTech/Dororo/releases"
const BAIDU_DOWNLOAD_URL = &"https://pan.baidu.com/s/1vcUQAhGckp3TWiJTuUUc_A?pwd=zcye"

var http_request: HTTPRequest

func _ready() -> void:
	$NinePatchRect/VBoxContainer/TitleBar.set_close_button_visibility(false)
	http_request = HTTPRequest.new()
	add_child(http_request)
	check_for_updates()
	
func check_for_updates():
	var error = http_request.request(API_URL)
	if error != OK:
		$NinePatchRect/VBoxContainer/MarginContainer/VBoxContainer/Message.set_text("无法获取最新版本，请检查网络设置！")
		return
	
	http_request.request_completed.connect(_on_request_completed)

func _on_request_completed(result, response_code, headers, body):
	if result != OK:
		$NinePatchRect/VBoxContainer/MarginContainer/VBoxContainer/Message.set_text("无法获取最新版本，请检查网络设置！")
		return
	
	if response_code != 200:
		$NinePatchRect/VBoxContainer/MarginContainer/VBoxContainer/Message.set_text("无法获取最新版本，请检查网络设置！")
		return
	
	var parsed_res = JSON.parse_string(body.get_string_from_utf8())
	
	if parsed_res != null:
		var current_version = ProjectSettings.get_setting("application/config/version")
		var latest_version = parsed_res[0]["name"]
		if is_update_available(current_version, latest_version):
			$NinePatchRect/VBoxContainer/MarginContainer/VBoxContainer/Message.set_text("发现最新版本：%s" % latest_version)
			$NinePatchRect/VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/OptionButton.show()
			$NinePatchRect/VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/JumpButton.show()
		else:
			$NinePatchRect/VBoxContainer/MarginContainer/VBoxContainer/Message.set_text("已是最新版本：v%s"% current_version)
		return
	else:
		$NinePatchRect/VBoxContainer/MarginContainer/VBoxContainer/Message.set_text("无法获取最新版本，请检查网络设置！")
		return

func is_update_available(current_version: String, latest_version: String) -> bool:
	var latest = latest_version.replace("v", "")
	
	# 分割版本号为数字数组
	var current_parts = current_version.split(".")
	var latest_parts = latest.split(".")
	
	# 比较每个部分
	for i in range(min(current_parts.size(), latest_parts.size())):
		var current_num = int(current_parts[i])
		var latest_num = int(latest_parts[i])
		
		if latest_num > current_num:
			return true
		elif latest_num < current_num:
			return false

	return latest_parts.size() > current_parts.size()
	
func _on_jump_button_pressed() -> void:
	match $NinePatchRect/VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/OptionButton.get_selected_id():
		0:
			OS.shell_open(BAIDU_DOWNLOAD_URL)
		1:
			OS.shell_open(GITHUB_DOWNLOAD_URL)

func _on_cancel_button_pressed() -> void:
	queue_free()
