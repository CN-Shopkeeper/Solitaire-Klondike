class_name ClassCard
extends Node

signal card_state_changed

var suit:String
var point:String


var is_flipped: bool = true:
	set(value):
		if is_flipped != value:
			is_flipped = value
			emit_signal("card_state_changed")
		
var is_on_top:bool=false:
	set(value):
		if is_on_top != value:
			is_on_top=value
			emit_signal("card_state_changed")

var _texture_path:String

func _init(_suit:String,_point:String) -> void:
	suit=_suit
	point=_point
	_texture_path="res://asserts/cards/%s_%s.png"%[suit,point]

func get_texture_path():
	return _texture_path

func equal(other: ClassCard) -> bool:
	return suit == other.suit and point == other.point
