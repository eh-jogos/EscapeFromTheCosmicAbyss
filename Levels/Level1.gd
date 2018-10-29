extends Node

var level_title = "Level 01"
var intro_beats = [1,1,1,1,1]
var intro_halfs = [0,0,1,0,0]
var end_beat = 4
var boss = {
	"boss_level": false,
	"laser_countdown":0,
	"scream": false,
	"countdown": 0,
	"sequence": []
}

var beats = {
	"none": 10,
	"tentacles": 15,
	"double_pipe":0,
	"triple_pipe":0,
	"wall": 0,
	"laser_eye": 0,
	"shield_up": 0,
	"ammo_up": 0
}

var half_beats = {
	"none": 18,
	"tentacles": 7,
	"double_pipe":0,
	"triple_pipe":0,
	"wall": 0,
	"laser_eye": 0,
	"shield_up": 0,
	"ammo_up": 0
}