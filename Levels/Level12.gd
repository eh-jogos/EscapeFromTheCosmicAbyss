extends Node

export(String) var title = ""
export(String, FILE) var intro_cutscene
export(String, FILE) var end_cutscene

var tutorial = false
var intro_beats = [0,0,0,0,0]
var intro_halfs =  [0,0,0,0,0]
var end_beat = 4
var boss = {
	"boss_level": true,
	"laser": true,
	"laser_countdowns":[10, 15, 32, 50, 70, 85, 90],
	"scream": true,
	"countdown": [5, 25, 45, 65, 80],
	"sequence_beats": [[5,2,3,6,2,3,3,5,2,2], [3,6,5,2,3,2,4,3,2,6], [4,3,5,3,6,3,3,5,2,3], [5,2,3,4,2,3,3,2,2,4], [3,2,3,6,2,3,4,5,3,6]],
	"sequence_halfs":  [[1,2,2,4,2,2,4,2,3,6], [2,4,3,2,4,5,2,3,3,4], [2,2,2,2,4,2,4,2,3,2], [4,3,3,6,2,5,4,3,2,2], [4,2,5,4,3,2,2,2,3,6]],
	"boss_node": "Boss",
	"animations": ["entrance", "to_angry", "scream", "to_angry", "scream", "to_angry", "scream", "to_angry", "last_scream", "tired_retreat"],
	"animations_countdowns": [4, 19, 24, 39, 44, 59, 64, 74, 79, 95],
}

var beats = {
	"none": 0,
	"tentacles": 0,
	"double_pipe": 20,
	"triple_pipe": 18,
	"wall": 2,
	"laser_eye": 2,
	"shield_up": 2,
	"ammo_up": 0
}

var half_beats = {
	"none": 10,
	"tentacles": 6,
	"double_pipe": 20,
	"triple_pipe": 8,
	"wall": 0,
	"laser_eye": 0,
	"shield_up": 0,
	"ammo_up": 0
}