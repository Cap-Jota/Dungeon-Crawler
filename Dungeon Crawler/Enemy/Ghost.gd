extends KinematicBody2D

const MAX_SPEED = 64
const ACCELERATION = 256

enum {
	IDLE,
	WANDER,
	CHASE
}

var direction = Vector2.ZERO
var wander_vector = Vector2.ZERO
var velocity = Vector2.ZERO
var state = IDLE
var target = Vector2.ZERO
var knockback = Vector2.ZERO

onready var stateTimer = $StateTimer
onready var stats = $Stats
onready var sprite = $AnimatedSprite
onready var playerDetector = $PlayerDetector
onready var hitAnimator = $HitAnimator

func _ready():
	randomize()
	state = pick_random_state()
	change_wander_direction()
	stateTimer.start(rand_range(1, 3))
	stats.connect("no_health", self, "queue_free")

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, ACCELERATION * delta)
	knockback = move_and_slide(knockback)
	
	chase_check()
	
	match state:
		IDLE:
			move(Vector2.ZERO, delta)

		WANDER:
			move(wander_vector, delta)

		CHASE:
			if playerDetector.player != null:
				target = playerDetector.player.global_position
				move(global_position.direction_to(target), delta)
			else:
				change_state(IDLE, rand_range(1, 3))

func move(vector: Vector2, delta):
	sprite.flip_h = vector.x > 0
	vector = vector.normalized()
	velocity = velocity.move_toward(vector * MAX_SPEED, ACCELERATION * delta)
	velocity = move_and_slide(velocity)

func change_wander_direction():
	wander_vector = Vector2(rand_range(-1, 1), rand_range(-1, 1))

func change_state(new_state, duration = 1):
	state = new_state
	change_wander_direction()
	stateTimer.start(duration)

func pick_random_state(states: Array = [IDLE, WANDER]):
	states.shuffle()
	return states.pop_front()

func chase_check():
	if playerDetector.player != null:
		state = CHASE

func _on_StateTimer_timeout():
	if state == IDLE:
		change_state(WANDER, rand_range(.5, 2))
	elif state == WANDER:
		change_state(IDLE, rand_range(1, 3))

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	hitAnimator.play("FireHit")
	knockback = area.knockback_vector * 128
	print(area.knockback_vector)
