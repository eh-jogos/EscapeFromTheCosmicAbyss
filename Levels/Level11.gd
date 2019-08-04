extends Node

export(String) var title = ""
export(String, FILE) var intro_cutscene
export(String, FILE) var end_cutscene

var tutorial = false
var intro_beats = [1,1,3,4,2]
var intro_halfs =  [0,2,2,1,3]
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
	"tentacles": 10,
	"double_pipe": 20,
	"triple_pipe": 14,
	"wall": 5,
	"laser_eye": 3,
	"shield_up": 2,
	"ammo_up": 0
}

var half_beats = {
	"none": 4,
	"tentacles": 16,
	"double_pipe": 18,
	"triple_pipe": 12,
	"wall": 2,
	"laser_eye": 0,
	"shield_up": 2,
	"ammo_up": 0
}