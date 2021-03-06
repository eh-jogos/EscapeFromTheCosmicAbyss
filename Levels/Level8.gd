extends Node

export(String) var title = ""
export(String, FILE) var intro_cutscene
export(String, FILE) var end_cutscene

var tutorial = false
var intro_beats = [1,2,1,2,4]
var intro_halfs =  [0,0,1,1,1]
var end_beat = 4
var boss = {
	"boss_level": false,
	"laser": false,
	"laser_countdowns":[],
	"scream": true,
	"countdown": [7],
	"sequence_beats": [[3,4,5,2,4,2,3,2,3,2,2]],
	"sequence_halfs":  [[2,2,6,2,3,2,5,2,2,6,4]],
	"boss_node": "MidBackRowBoss",
	"animations": ["scream"],
	"animations_countdowns": [5],
	"danger_durations": [11],
}

var beats = {
	"none": 0,
	"tentacles": 12,
	"double_pipe": 11,
	"triple_pipe": 11,
	"wall": 6,
	"laser_eye": 1,
	"shield_up": 2,
	"ammo_up": 0
}

var half_beats = {
	"none": 13,
	"tentacles": 10,
	"double_pipe": 10,
	"triple_pipe": 5,
	"wall": 4,
	"laser_eye": 0,
	"shield_up": 1,
	"ammo_up": 0
}
