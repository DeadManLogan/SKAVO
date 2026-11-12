extends Node2D


func _ready() -> void:
	# Integer scaling can't go below 1x, so a window smaller than the viewport crops the game
	# and clicks stop lining up with what's drawn. content_scale_size is the 640x360 viewport size.
	get_window().min_size = get_window().content_scale_size
