extends Node

export(String) var title = ""
export(String, FILE) var intro_cutscene
export(String, FILE) var end_cutscene

var tutorial = false
var intro_beats = [1,1,2,1,3]
var intro_halfs =  [0,0,0,0,0]
var end_beat = 4
var boss = {
	"boss_level": false,
	"laser": false,
	"laser_countdowns":[],
	"scream": true,
	"countdown": [25],
	"sequence_beats": [[2,3,4,2,3,2,3]],
	"sequence_halfs":  [[3,2,3,6,5,4,2]],
	"boss_node": "BackRowBoss",
	"animations": ["awaken", "get_angry", "scream"],
	"animations_countdowns": [8,15,25],
	"danger_durations": [0, 0, 7],
}

var beats = {
	"none": 0,
	"tentacles": 20,
	"double_pipe": 10,
	"triple_pipe": 8,
	"wall": 5,
	"laser_eye": 2,
	"shield_up": 0,
	"ammo_up": 0
}

var half_beats = {
	"none": 35,
	"tentacles": 5,
	"double_pipe": 4,
	"triple_pipe": 0,
	"wall": 0,
	"laser_eye": 0,
	"shield_up": 1,
	"ammo_up": 0
}
