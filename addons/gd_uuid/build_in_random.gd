class_name BuildInRandom
extends CryptoRandom

var _random = RandomNumberGenerator.new()


func _init():
	var seed = 0
	var seed_bytes = _crypto.generate_random_bytes(4)
	seed |= seed_bytes[0] << 24
	seed |= seed_bytes[1] << 16
	seed |= seed_bytes[2] << 8
	seed |= seed_bytes[3]
	_random.seed = seed


func bytes(size: int) -> PackedByteArray:
	var len_ints = (size + 3) / 4

	var ints = PackedInt32Array()
	ints.resize(len_ints)

	for index in range(len_ints):
		ints[index] = _random.randi()

	return ints.to_byte_array()
