class_name CryptoRandom
extends BaseRandom

static var _crypto = Crypto.new()


func bytes(size: int) -> PackedByteArray:
	return _crypto.generate_random_bytes(size)
