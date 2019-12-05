extends Area2D
class_name BonusMana2

onready var scn_particle = preload("res://scenes/bullets/delete.tscn")
#onready var particle_texture = load("res://textures/bullet.png")

var texture = preload("res://textures/snow.png")
var SOUND_HIT = audio_player.SOUND.BULLET_HIT1

const AMOUNT_MANA := 5

func _ready():
	var sprite := Sprite.new()
	sprite.texture = texture
	sprite.scale *= 0.5
	sprite.modulate = Color(0.7,0.9,1.1)
	add_child(sprite)
	
	var shape := CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	add_child(shape)
	
	var visibler := VisibilityNotifier2D.new()
	visibler.scale = Vector2(2,2)
	visibler.connect("screen_exited", self, "queue_free")
	add_child(visibler)
	
	connect("body_entered", self, "_on_body_enter")

var x:float = 0.0
func _process(delta):
	x += delta
	translate(Vector2(cos(x),1))

func get_mana_amount()->int:
	return AMOUNT_MANA

func delete(is_label=true):
	audio_player.play(SOUND_HIT, -12)
	#
	var p := scn_particle.instance() as CPUParticles2D
	p.position = position
	p.texture = texture
	p.modulate = Color(0.7,0.9,1.1)
	get_parent().add_child(p)
	#
	if is_label:
		var lbl := Label.new()
		lbl.text = "+"+str(AMOUNT_MANA) + " MANA"
		p.add_child(lbl)
		lbl.rect_global_position = global_position
		lbl.modulate = Color(0.1,0.8,0.1)
	queue_free()

func _on_body_enter(body):
	delete(false)
