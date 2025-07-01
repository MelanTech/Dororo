class_name BindingWithPipeline

var _with_pipe: Array[Callable] = []

func _init(with_pipe: Array[Callable] = []) -> void:
	_with_pipe = with_pipe

func append(with_func: Callable):
	_with_pipe.append(with_func)

func copy():
	return BindingWithPipeline.new(_with_pipe.duplicate())
	
func get_pipeline() ->  Array[Callable]:
	return _with_pipe
