class_name BaseRandom


func bytes(size: int) -> PackedByteArray:
	var result = PackedByteArray()
	result.resize(size)
	return result
