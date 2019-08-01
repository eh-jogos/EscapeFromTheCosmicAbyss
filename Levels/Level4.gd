extends Node

export(String) var title = ""
export(String, FILE) var intro_cutscene
export(String, FILE) var end_cutscene

var tutorial = false
var intro_beats = [1,1,1,1,3]
var intro_halfs = [0,0,0,0,0]
var end_beat = 4
var boss = {
	"boss_level": false,
	"laser": false,
	"laser_countdown":[],
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
	"tentacles": 30,
	"double_pipe": 10,
	"triple_pipe": 8,
	"wall": 2,
	"laser_eye": 0,
	"shield_up": 0,
	"ammo_up": 0
}

var half_beats = {
	"none": 40,
	"tentacles": 5,
	"double_pipe": 3,
	"triple_pipe": 2,
	"wall": 0,
	"laser_eye": 0,
	"shield_up": 0,
	"ammo_up": 0
}