extends CanvasLayer
class_name Character_ui

onready var n_health = $health
onready var n_mana = $mana
onready var n_bullets = $bullets

func _ready():
	for b in n_bullets.get_children():
		b.get_node("label").text = str(objects.get_bullet_cost(int(b.name)))

func set_health(health:int):
	n_health.value = health
	print(n_health.value)

func set_mana(mana:int):
	n_mana.value = mana

func select_bullet(bullet:int):
	var type = str(bullet)
	for b in n_bullets.get_children():
		if b.name == type:
			b.rect_scale = Vector2(1.5,1.5)
		else:
			b.rect_scale = Vector2(1,1)
