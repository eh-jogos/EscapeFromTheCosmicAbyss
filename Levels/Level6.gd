extends Node

@export var title: String = ""
@export_file var intro_cutscene
@export_file var end_cutscene

var tutorial = false
var intro_beats = [1,2,3,2,3]
var intro_halfs =  [0,0,0,1,0]
var end_beat = 4
var boss = {
	"boss_level": false,
	"laser": false,
	"laser_countdowns":[],
	"scream": false,
	"countdown": [],
	"sequence_beats": [],
	"sequence_halfs": [],
	"boss_node": null,
	"animations": [],
	"animations_countdowns": [],
}

var beats = {
	"none": 0,
	"tentacles": 0,
	"double_tentacle": 16,
	"triple_tentacle": 12,
	"wall_tentacle": 3,
	"laser_eye": 2,
	"shield_up": 2,
	"ammo_up": 0
}

var half_beats = {
	"none": 20,
	"tentacles": 7,
	"double_tentacle": 3,
	"triple_tentacle": 3,
	"wall_tentacle": 2,
	"laser_eye": 0,
	"shield_up": 0,
	"ammo_up": 0
}
