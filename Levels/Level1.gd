extends Node

var level_title = "Level 01"
var intro_beats = [2,2,2,2,2]
var intro_halfs = [0,0,3,0,0]
var end_beat = 1
var boss = {
	"boss_level": false,
	"laser_countdown":0,
	"scream": false,
	"countdown": 0,
	"sequence": []
}

var beats = {
	"none": 0,
	"tentacles": 0,
	"double_pipe":0,
	"triple_pipe":25,
	"wall": 0,
	"laser_eye": 0,
	"shield_up": 0,
	"ammo_up": 0
}

var half_beats = {
	"none": 18,
	"tentacles": 0,
	"double_pipe":0,
	"triple_pipe":7,
	"wall": 0,
	"laser_eye": 0,
	"shield_up": 0,
	"ammo_up": 0
}