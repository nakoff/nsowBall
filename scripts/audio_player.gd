extends Node

enum SOUND {
	SWING1=0,SWING2,SWING3,SWING4,SWING5,
	BULLET_HIT1,BULLET_HIT2,BULLET_HIT3,
	DMG1,DMG2,DMG3,DMG4,DMG5,DMG6,
	JUMP1,JUMP2,
}
var sounds = { 
	SOUND.SWING1: preload("res://sounds/characters/swing1.ogg"),
	SOUND.SWING2: preload("res://sounds/characters/swing2.ogg"),
	SOUND.SWING3: preload("res://sounds/characters/swing3.ogg"),
	SOUND.SWING4: preload("res://sounds/characters/swing4.ogg"),
	SOUND.SWING5: preload("res://sounds/characters/swing5.ogg"),
	SOUND.BULLET_HIT1: preload("res://sounds/bullets/hit1.ogg"),
	SOUND.BULLET_HIT2: preload("res://sounds/bullets/hit2.ogg"),
	SOUND.BULLET_HIT3: preload("res://sounds/bullets/hit3.ogg"),
	SOUND.DMG1: preload("res://sounds/characters/damage1.ogg"),
	SOUND.DMG2: preload("res://sounds/characters/damage2.ogg"),
	SOUND.DMG3: preload("res://sounds/characters/damage3.ogg"),
	SOUND.DMG4: preload("res://sounds/characters/damage4.ogg"),
	SOUND.DMG5: preload("res://sounds/characters/cough1.ogg"),
	SOUND.DMG6: preload("res://sounds/characters/cough2.ogg"),
	SOUND.JUMP1: preload("res://sounds/characters/jump1.ogg"),
	SOUND.JUMP2: preload("res://sounds/characters/jump2.ogg"),
}

onready var lvl = get_tree().root.get_child(0)

func play(sound_name:int, volume:int=0):
	var player := AudioStreamPlayer2D.new()
	player.stream = sounds[sound_name]
	player.volume_db = volume
	lvl.add_child(player)
	player.connect("finished", player, "queue_free")
	player.play()
