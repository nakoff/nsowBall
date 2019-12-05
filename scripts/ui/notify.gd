extends Control
class_name Notify

onready var restart_ok := $restart/ok
onready var restart_cl := $restart/cancel
onready var move_ok := $movement/ok
onready var time_ok := $time/ok
onready var shoot2_ok := $shoot2/ok
onready var bullets_ok := $bullets/ok
onready var mana_ok := $mana/ok

enum WINDOWS {RESTART=0,MOVE,TIME,SHOOT2,BULLETS,MANA} 

onready var _win = [
	$restart, $movement, $time, $shoot2, $bullets, $mana
]

# Called when the node enters the scene tree for the first time.
func _ready():
	restart_ok.connect("pressed", self, "_on_restart", [restart_ok])
	restart_cl.connect("pressed", self, "_on_btn_pressed", [restart_cl])
	move_ok.connect("pressed", self, "_on_btn_pressed", [move_ok])
	time_ok.connect("pressed", self, "_on_btn_pressed", [time_ok])
	shoot2_ok.connect("pressed", self, "_on_btn_pressed", [shoot2_ok])
	bullets_ok.connect("pressed", self, "_on_btn_pressed", [bullets_ok])
	mana_ok.connect("pressed", self, "_on_btn_pressed", [mana_ok])

func show_window(win:int, ok_only=false):
	get_tree().paused = true
	_win[win].show()
	restart_cl.show()
	if ok_only:
		restart_cl.hide()

func _on_restart(btn:Button):
	btn.get_parent().hide()
	get_tree().paused = false
	
	objects.restart()

func _on_btn_pressed(btn:Button):
	var p := btn.get_parent()
	p.hide()
	get_tree().paused = false
	
