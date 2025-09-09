extends Node
class_name ResponseParser

var _cache: String = ""
var _json: JSON = JSON.new()

signal on_response(content: String)
signal on_thinking(content: String)
signal on_finish
signal on_error(message: String)

func process(response: String):
	if response.is_empty():
		on_finish.emit()
		return
			
	if response.begins_with("data: "):
		response = response.substr("data: ".length())
		
	if _json.parse(response) == OK:
		var data = _json.get_data()
		if data.has("error"):
			on_error.emit(data.error.message)
			
		if data.has("choices") and data.choices.size() > 0:
			var choice = data.choices[0]
			
			if choice.has("message"):
				if choice["message"].has("reasoning_content"):
					on_thinking.emit(choice.message.reasoning_content)
				if choice["message"].has("content"):
					on_response.emit(choice.message.content)
				
	on_finish.emit()

func process_stream(response: String):
	response += _cache
	_cache = ""
	
	var lines = response.split("\n")
	
	for line in lines:
		#prints("LINE: ", line)
		line = line.strip_edges()
		
		if line.is_empty():
			continue
			
		if line.begins_with("data: "):
			line = line.substr("data: ".length())
		
		if line == "[DONE]":
			#print("STOP")
			on_finish.emit()
			break
		
		if _json.parse(line) == OK:
			var data = _json.get_data()
			if data.has("error"):
				on_error.emit(data.error.message)
				
			if data.has("choices") and data.choices.size() > 0:
				var choice = data.choices[0]
				if choice.has("finish_reason") and choice.finish_reason == "stop":
					#print("STOP")
					on_finish.emit()
					break
				elif choice.delta.has("reasoning_content"):
					on_thinking.emit(choice.delta.reasoning_content)
				elif choice.delta.has("content"):
					on_response.emit(choice.delta.content)
		else:
			#print('Parse Error')
			_cache = line
			break
			

func clear_cache():
	_cache = ""
