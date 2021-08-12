extends KinematicBody2D

const Fireball = preload("res://Player/Fireball.tscn")
const HitEffect = preload("res://Effects/Hit Effect.tscn")

const MAX_SPEED = 128
const ACCELERATION = 512
const FRICTION = 512

enum {
	MOVE,
	FLY
}

var input_vector = Vector2.ZERO
var velocity = Vector2.ZERO
var fireball_vector = Vector2.ZERO
var state = MOVE
var can_shot = true
var imortal = false

onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var firePosition = $Sprite/FirePosition
onready var shotTimer = $ShotTimer
onready var hitPlayer = $HitPlayer

func _ready():
	fireball_vector = Vector2.DOWN
	animationTree.active = true
	PlayerStats.connect("no_health", self, "queue_free")

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		
		FLY:
			pass

func move_state(delta): 
	input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		fireball_vector = input_vector
		
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		
		animationState.travel("Run")
	else:
		animationState.travel("Idle")
		
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	if Input.is_action_pressed("attack"):
		cast_fireball()
	
	move()

func move():
	velocity = move_and_slide(velocity)

func cast_fireball():
	if can_shot:
		var fireball = Fireball.instance()
		get_parent().add_child(fireball)
		fireball.velocity = fireball_vector
		fireball.global_position = firePosition.global_position
		fireball.rotation = fireball_vector.angle()
		can_shot = false
		shotTimer.start()

func creat_hit_effect():
	var hitEffect = HitEffect.instance()
	var main = get_tree().current_scene
	main.add_child(hitEffect)
	hitEffect.global_position = global_position

func _on_ShotTimer_timeout():
	can_shot = true

func _on_Hurtbox_area_entered(area):
	PlayerStats.health -= area.damage
	hitPlayer.play("Blink")
	creat_hit_effect()
