extends RigidBody2D

class_name Bullet

export (PackedScene) var s_particle
export (Texture) var particle_texture

var health := 1
var character:KinematicBody2D
var _damage:int = 5
var SOUND_HIT = audio_player.SOUND.BULLET_HIT1

func _ready():
	assert(s_particle)

func _on_bullet_body_enter(body):
	if body is RigidBody2D:
		get_parent().camera_shake(body)
	health -=1
	if health < 1:
		delete()

func get_damage()->int:
	return _damage

func _on_Timer_timeout():
	delete()

func delete():
	audio_player.play(SOUND_HIT, -12)
	var p = s_particle.instance()
	p.position = position
	get_parent().add_child(p)
	queue_free()
