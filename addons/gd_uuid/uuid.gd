class_name UUID

static var fallback_random = BuildInRandom.new()


static func v7(random: BaseRandom = fallback_random) -> String:
	var bytes = PackedByteArray()
	bytes.resize(16)

	var unix_time_ms = get_unix_time_ms()
	var rands = random.bytes(10)

	bytes[0] = (unix_time_ms >> 40) & 0xff
	bytes[1] = (unix_time_ms >> 32) & 0xff
	bytes[2] = (unix_time_ms >> 24) & 0xff
	bytes[3] = (unix_time_ms >> 16) & 0xff

	bytes[4] = (unix_time_ms >> 8) & 0xff
	bytes[5] = unix_time_ms & 0xff
	bytes[6] = 0x70 | (rands[0] & 0x0f)
	bytes[7] = rands[1]

	bytes[8] = 0x80 | rands[2] & 0x3f
	bytes[9] = rands[3]
	bytes[10] = rands[4]
	bytes[11] = rands[5]

	bytes[12] = rands[6]
	bytes[13] = rands[7]
	bytes[14] = rands[8]
	bytes[15] = rands[9]

	return format(bytes)


static func get_unix_time_ms() -> int:
	return int(Time.get_unix_time_from_system() * 1000)


static func format(bytes: PackedByteArray) -> String:
	return "%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x" % Array(bytes)
