extends Node2D

export(int) var max_health = 1 setget set_max_health
var health = 1 setget set_health

signal no_health
signal max_health_changed(value)
signal heath_changed(value)

func _ready():
	self.health = max_health

func set_max_health(value):
	value = max(1, value)
	max_health = value
	emit_signal("max_health_changed", value)

func set_health(value):
	health = clamp(value, 0, max_health)
	if health <= 0:
		emit_signal("no_health")
	emit_signal("heath_changed", health)
