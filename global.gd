extends Node

@onready var setts := ConfigFile.new()

func _ready() -> void:
	setts.load("res://settings.ini")
