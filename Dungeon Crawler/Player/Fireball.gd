extends Node2D

var fireballEffect = preload("res://Effects/FireballEffect.tscn")

var velocity = Vector2.ZERO

export var speed = 128

onready var hitbox = $Hitbox

func _physics_process(delta):
	position += velocity * speed * delta
	hitbox.knockback_vector = velocity

func create_fireball_effect():
	var effect = fireballEffect.instance()
	get_parent().add_child(effect)
	effect.global_position = global_position

func _exit_tree():
	create_fireball_effect()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_Hitbox_area_entered(area):
	queue_free()

func _on_Hitbox_body_entered(body):
	queue_free()
