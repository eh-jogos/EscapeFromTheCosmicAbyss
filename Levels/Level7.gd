extends Node

export(String) var title = ""
export(String, FILE) var intro_cutscene
export(String, FILE) var end_cutscene

var tutorial = false
var intro_beats = [1,1,5,1,1]
var intro_halfs =  [0,0,0,1,3]
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
	"tentacles": 15,
	"double_pipe": 12,
	"triple_pipe": 10,
	"wall": 4,
	"laser_eye": 4,
	"shield_up": 4,
	"ammo_up": 0
}

var half_beats = {
	"none": 30,
	"tentacles": 15,
	"double_pipe": 0,
	"triple_pipe": 0,
	"wall": 1,
	"laser_eye": 3,
	"shield_up": 0,
	"ammo_up": 0
}
