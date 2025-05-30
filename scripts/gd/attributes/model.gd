extends Node2D

@export var flip_h: bool = false:
	get:
		return flip_h
	set(flip):
		flip_h = flip
		if flip_h:
			set_scale(Vector2(-1, 1))
		else:
			set_scale(Vector2(1, 1))
