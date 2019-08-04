extends Node

export(String) var title = ""
export(String, FILE) var intro_cutscene
export(String, FILE) var end_cutscene

var tutorial = false
var intro_beats = [1,2,1,2,1]
var intro_halfs =  [1,0,1,0,1]
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
	"tentacles": 18,
	"double_pipe": 12,
	"triple_pipe": 6,
	"wall": 4,
	"laser_eye": 1,
	"shield_up": 1,
	"ammo_up": 0
}

var half_beats = {
	"none": 21,
	"tentacles": 12,
	"double_pipe": 6,
	"triple_pipe": 3,
	"wall": 0,
	"laser_eye": 0,
	"shield_up": 0,
	"ammo_up": 0
}