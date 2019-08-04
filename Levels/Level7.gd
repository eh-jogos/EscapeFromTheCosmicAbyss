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
	"tentacles": 20,
	"double_pipe": 12,
	"triple_pipe": 10,
	"wall": 4,
	"laser_eye": 6,
	"shield_up": 2,
	"ammo_up": 0
}

var half_beats = {
	"none": 32,
	"tentacles": 10,
	"double_pipe": 5,
	"triple_pipe": 3,
	"wall": 1,
	"laser_eye": 1,
	"shield_up": 2,
	"ammo_up": 0
}