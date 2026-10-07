extends Node2D

const level_2 = preload("res://scenes/level_2.tscn")
@onready var level_1 = $level_1
@export var collected_crowns: int = 0

func change_level() -> void:
	add_child(level_2.instantiate())
	level_1.queue_free()
	
