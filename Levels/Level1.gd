extends Node

export(String) var title = ""
export(String, FILE) var intro_cutscene
export(String, FILE) var end_cutscene

var tutorial = false
var intro_beats = [1,1,1,1,1]
var intro_halfs = [0,0,0,0,0]
var end_beat = 1
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
	"tentacles": 25, 
	"double_pipe":0,
	"triple_pipe":0,
	"wall": 0,
	"laser_eye": 0,
	"shield_up": 0,
	"ammo_up": 0
}

var half_beats = {
	"none": 25,
	"tentacles": 0,
	"double_pipe":0,
	"triple_pipe":0,
	"wall": 0,
	"laser_eye": 0,
	"shield_up": 0,
	"ammo_up": 0
}