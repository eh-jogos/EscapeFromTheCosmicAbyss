extends Node

export(String) var title = ""
export(String, FILE) var intro_cutscene
export(String, FILE) var end_cutscene

var tutorial = false
var intro_beats = [1,1,2,2,3]
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
	"tentacles": 5,
	"double_pipe": 16,
	"triple_pipe": 16,
	"wall": 3,
	"laser_eye": 2,
	"shield_up": 2,
	"ammo_up": 0
}

var half_beats = {
	"none": 20,
	"tentacles": 12,
	"double_pipe": 5,
	"triple_pipe": 5,
	"wall": 2,
	"laser_eye": 0,
	"shield_up": 0,
	"ammo_up": 0
}