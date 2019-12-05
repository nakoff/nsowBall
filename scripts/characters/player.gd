extends KinematicBody2D

class_name Player

export (NodePath) var p_body
export (NodePath) var p_bullet_piv
export (NodePath) var p_anim_arms
export (NodePath) var p_anim_legs
export (NodePath) var p_ui
export (NodePath) var p_notify

var notify:Notify 
var ui:Character_ui
var anm_arms:AnimationPlayer
var anm_legs:AnimationPlayer
var n_bullet_piv:Node2D
var n_body:Node2D

onready var n_skin := $skin
onready var n_tween := $tween
onready var timer_bullet_time := Timer.new()

var _health:int
var _mana:int

const GRAVITY_VEC = Vector2(0, 900)
const FLOOR_NORMAL = Vector2(0, -1)
const SLOPE_SLIDE_STOP = 25.0
const WALK_SPEED = 250 # pixels/sec
const JUMP_SPEED = 480
const SIDING_CHANGE_SPEED = 10
const BULLET_VELOCITY = 1000
const SHOOT_TIME_SHOW_WEAPON = 0.2

const ANM_SHOOT = "shoot"
const ANM_SHOOT_START = "shoot_start"
const ANM_SHOOT_END = "shoot_end"
const ANM_RELOAD = "reload"
const ANM_WALK = "walk"
const ANM_IDLE = "idle"

const SND_SWINGS := [audio_player.SOUND.SWING1,audio_player.SOUND.SWING2]
const SND_JUMPS := [audio_player.SOUND.JUMP1,audio_player.SOUND.JUMP2]
const SND_DMGS := [
	audio_player.SOUND.DMG1,audio_player.SOUND.DMG2,audio_player.SOUND.DMG3,
	audio_player.SOUND.DMG4,audio_player.SOUND.DMG5,audio_player.SOUND.DMG6]

var linear_vel = Vector2()
var dir:int = 1
var m_pos:Vector2
var shoot_pressed := false

var run_anims = {
	ANM_SHOOT: false,
	ANM_WALK: false,
	ANM_IDLE: false
}

var bullets = [
	objects.BULLETS.SNOW,
	objects.BULLETS.YELLOW_SNOW,
	objects.BULLETS.ICE,
]
var curr_bullet = 0

func set_dir(new_dir):
	if dir != new_dir:
		dir = new_dir
		n_skin.scale.x = dir * 0.2

func _ready():
	assert(p_body)
	assert(p_bullet_piv)
	assert(p_anim_arms)
	assert(p_anim_legs)
	assert(p_ui)
	assert(p_notify)
	
	notify = get_node(p_notify)
	ui = get_node(p_ui)
	anm_arms = get_node(p_anim_arms)
	anm_legs = get_node(p_anim_legs)
	n_body = get_node(p_body)
	n_bullet_piv = get_node(p_bullet_piv)
	
	timer_bullet_time.wait_time = 0.1
	timer_bullet_time.connect("timeout", self, "_on_timeout", [timer_bullet_time])
	add_child(timer_bullet_time)
	
	n_skin.connect("collided", self, "_on_body_enter")
	anm_arms.connect("animation_finished", self, "_on_anim_finished")
	set_bullet(curr_bullet)
	set_health(100)
	set_mana(100)
	
	n_tween.interpolate_callback(notify, 1, "show_window", notify.WINDOWS.MOVE)
	n_tween.interpolate_callback(notify, 6, "show_window", notify.WINDOWS.BULLETS)
	n_tween.interpolate_callback(notify, 12, "show_window", notify.WINDOWS.MANA)
	n_tween.interpolate_callback(notify, 25, "show_window", notify.WINDOWS.SHOOT2)
	n_tween.interpolate_callback(notify, 35, "show_window", notify.WINDOWS.TIME)
	n_tween.start()
	
	objects.set_player(self)

func restart():
	set_health(100)
	set_mana(100)
	set_bullet(0)

func set_bullet(val:int):
	if val < 0: val = 0
	elif val > bullets.size() - 1: val = bullets.size() - 1
	
	curr_bullet = val
	ui.select_bullet(bullets[curr_bullet])

func _input(event):
	if event is InputEventMouseButton:
		shoot_pressed = false
		# Shooting
		if Input.is_action_just_pressed(ANM_SHOOT): 
			if not run_anims[ANM_SHOOT]:
				if _mana >= objects.get_bullet_cost(bullets[curr_bullet]):
					anm_arms.play(ANM_SHOOT, 0.2, 3)
					run_anims[ANM_SHOOT] = true
					n_tween.interpolate_callback(audio_player, 0.3, "play", SND_SWINGS[randi()%SND_SWINGS.size()-1], -15)
					n_tween.start()
		elif Input.is_action_just_pressed("shoot2"):
			if _mana >= objects.get_bullet_cost(bullets[curr_bullet]) * 3:
				shoot_pressed = true
		elif event.is_action_pressed("bullet_next"):
			set_bullet(curr_bullet + 1)
		elif event.is_action_pressed("bullet_prev"):
			set_bullet(curr_bullet - 1)
	if event is InputEventMouseMotion: 
		m_pos = event.position
		n_body.look_at(m_pos)
		if n_body.rotation_degrees > 60:
			n_body.rotation_degrees = 60
		elif n_body.rotation_degrees < -70:
			n_body.rotation_degrees = -70
	if event is InputEventKey:
		if Input.is_action_just_pressed("ui_cancel"):
			notify.show_window(notify.WINDOWS.RESTART)
		if Input.is_action_just_pressed("time"):
			if _mana > 0:
				timer_bullet_time.start()
				Engine.time_scale = 0.2
				_on_timeout(timer_bullet_time)
		elif Input.is_action_just_released("time"):
			timer_bullet_time.stop()
			Engine.time_scale = 1
		if event.pressed:
			# Jumping
			var on_floor = is_on_floor()
			if on_floor and Input.is_action_just_pressed("jump"):
				linear_vel.y = -JUMP_SPEED
				audio_player.play(SND_JUMPS[randi()%SND_JUMPS.size()-1], -10)
			else:
				# bullet change
				var key = int(OS.get_scancode_string(event.scancode))
				if key: set_bullet(key-1)

var is_shoot2:bool
var shoot2_force:float
func _process(delta):
	if shoot_pressed:
		if not run_anims[ANM_SHOOT]:
			anm_arms.play(ANM_SHOOT_START, 0.2, 0.8)
			run_anims[ANM_SHOOT] = true
			is_shoot2 = true
	elif is_shoot2:
			is_shoot2 = false
			shoot2_force = anm_arms.get_current_animation_position() * 1000
			anm_arms.play(ANM_SHOOT_END, -1, 3)

func _physics_process(delta):
	linear_vel += delta * GRAVITY_VEC
	linear_vel = move_and_slide(linear_vel, FLOOR_NORMAL, SLOPE_SLIDE_STOP)
	#
	var target_speed = 0
	if Input.is_action_pressed("move_left"):
		target_speed -= 1
	if Input.is_action_pressed("move_right"):
		target_speed += 1
	#
	target_speed *= WALK_SPEED
	linear_vel.x = lerp(linear_vel.x, target_speed, 0.1)
	#
	if abs(linear_vel.x) > 20:
		run_anims[ANM_IDLE] = false
		if not run_anims[ANM_WALK]:
			anm_legs.play(ANM_WALK, 0.2,2)
			run_anims[ANM_WALK] = true
	else:
		run_anims[ANM_WALK] = false
		if not run_anims[ANM_IDLE]:
			anm_legs.play(ANM_IDLE)
			run_anims[ANM_IDLE] = true

func set_health(new_health:int):
	if new_health < 0: 
		new_health = 0
		notify.show_window(notify.WINDOWS.RESTART, true)
	elif new_health > 100: new_health = 100
	_health = new_health
	ui.set_health(_health)

func get_health()->int:
	return _health

func set_mana(new_mana:int):
	if new_mana < 0: new_mana = 0
	elif new_mana > 100: new_mana = 100
	_mana = new_mana
	ui.set_mana(_mana)

func get_mana()->int:
	return _mana

func shoot(is_shoot2:bool):
	var bullet:RigidBody2D
	var rnd:float
	var amount:int = 1
	var shoot_force:int = BULLET_VELOCITY
	var type_bullet := bullets[curr_bullet] as int
	
	if is_shoot2:
		amount = 3
		shoot_force = shoot2_force
	
	set_mana(_mana - objects.get_bullet_cost(type_bullet) * amount)
	
	var bullets := []
	
	for i in range(amount):
		bullet = objects.get_obj(type_bullet) as RigidBody2D
		bullet.position = n_bullet_piv.global_position
		#
		rnd = rand_range(-0.2,0.2)
		bullet.rotate(n_body.global_rotation*dir + rnd)
		var force = Vector2(shoot_force,0).rotated(bullet.rotation)
		bullet.linear_velocity = force 
		bullet.add_collision_exception_with(self)
		for b in bullets:
			bullet.add_collision_exception_with(b)
		bullets.push_back(bullet)
		get_parent().add_child(bullet)
		bullet.character = self
	bullets.clear()

func _on_anim_finished(anim_name:String):
	if anim_name == ANM_SHOOT or anim_name == ANM_SHOOT_END:
		var is_shoot2:bool
		#
		if anim_name == ANM_SHOOT_END:
			is_shoot2 = true
		shoot(is_shoot2)
		anm_arms.play(ANM_RELOAD, 0.2, 3)
	elif anim_name == ANM_RELOAD:
		run_anims[ANM_SHOOT] = false

func _on_body_enter(body):
	if body is Bullet:
		set_health(_health - body.get_damage())
		audio_player.play(SND_DMGS[randi()%SND_DMGS.size()-1], -2)
		body.delete()
	elif body is BonusMana:
		set_mana(_mana + body.get_mana_amount())
		body.delete(true)
		

func _on_timeout(tmr:Timer):
	if tmr == timer_bullet_time:
		set_mana(_mana - 1)
		if _mana < 1:
			timer_bullet_time.stop()
			Engine.time_scale = 1
