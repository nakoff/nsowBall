extends Node

enum CHARACTERS {PLAYER=0, ENEMY=1}
enum BULLETS {SNOW=10, YELLOW_SNOW=11, ICE=12}

var _player
var _enemy

var _bullet_costs = {
	BULLETS.SNOW: 1,
	BULLETS.YELLOW_SNOW: 3,
	BULLETS.ICE: 5,
}

func get_bullet_cost(bullet:int):
	return _bullet_costs[bullet]

onready var _scenes = {
	BULLETS.SNOW: preload("res://scenes/bullets/snow.tscn"),
	BULLETS.YELLOW_SNOW: preload("res://scenes/bullets/yellow_snow.tscn"),
	BULLETS.ICE: preload("res://scenes/bullets/ice.tscn"),
}

func get_obj(type)->Node2D:
	if _scenes.has(type):
		return _scenes[type].instance()
	return null

func set_player(player): 
	_player = player 

func get_player():
	return _player

func set_enemy(enemy):
	_enemy = enemy

func get_enemy():
	return _enemy

func restart():
	_player.restart()
	_enemy.restart()
