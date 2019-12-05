extends Node2D

onready var timer := Timer.new()
onready var n_tween := $tween
onready var n_cam := $camera

var s_bonus_mana = preload("res://scenes/bonuses/mana.tscn")

var _is_shake:bool

func _ready():
	timer.wait_time = 2
	timer.connect("timeout", self, "timeout")
	n_tween.connect("tween_completed", self, "_on_tween_finished")
	add_child(timer)
	timer.start()

func restart():
	pass
	objects.restart()

func camera_shake(body):
	if body is Bullet and !_is_shake:
		_is_shake = true
		n_tween.interpolate_method(self, "_shake", 1,30, 0.5, Tween.TRANS_LINEAR,Tween.EASE_OUT)
		n_tween.start()

func _shake(t:int):
	n_cam.position.x += cos(t)
	n_cam.position.y += sin(t)

func timeout():
	var mana = s_bonus_mana.instance()
	mana.position = Vector2(rand_range(40,1200), 10)
	add_child(mana)
	timer.wait_time = rand_range(0.3,2)

func _on_tween_finished(obj, name:String):
	_is_shake = false
	n_cam.position = Vector2(0,0)
