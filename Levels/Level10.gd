extends Node

export(String) var title = ""
export(String, FILE) var intro_cutscene
export(String, FILE) var end_cutscene

var tutorial = false
var intro_beats = [3,2,5,1,4]
var intro_halfs =  [1,0,0,1,6]
var end_beat = 4
var boss = {
	"boss_level": false,
	"laser": false,
	"laser_countdowns":[],
	"scream": true,
	"countdown": [35],
	"sequence_beats": [[3,2,2,4,3,6,5,2,3,2,5,3,2,6,2]],
	"sequence_halfs":  [[2,4,5,2,2,3,2,4,6,2,3,2,2,3,4]],
	"boss_node": "MidFrontRowBoss",
	"animations": ["scream"],
	"animations_countdowns": [34],
}

var beats = {
	"none": 0,
	"tentacles": 14,
	"double_pipe": 25,
	"triple_pipe": 15,
	"wall": 4,
	"laser_eye": 3,
	"shield_up": 3,
	"ammo_up": 0
}

var half_beats = {
	"none": 30,
	"tentacles": 13,
	"double_pipe": 14,
	"triple_pipe": 6,
	"wall": 0,
	"laser_eye": 0,
	"shield_up": 1,
	"ammo_up": 0
}
