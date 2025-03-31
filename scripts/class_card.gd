class_name ClassCard
extends Node

signal card_state_changed

var owning_node:WeakRef

var suit:String
var point:String

# 是否处于一个顺序的牌组中
var is_in_order:bool = false:
	set(value):
		#if is_in_order != value:
		is_in_order = value
		emit_signal("card_state_changed")

# 是否被翻面
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

# 是否已经完成
var is_completed:bool=false:
	set(value):
		# 该值会被多次赋值，但是理论上只会改变一次	
		if is_completed != value:
			is_completed=value
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
