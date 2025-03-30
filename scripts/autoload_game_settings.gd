extends Node

const CARD_BACK_BLUE = preload("res://asserts/cards/card_back_blue.png")
const CARD_BACK_RED = preload("res://asserts/cards/card_back_red.png")


const STOCK_TO_WASTE_DURATION=0.1
const WASTE_TO_STOCK_DURATION=0.05
const WASTE_TO_STOCK_DELAY = 0.02

var _is_game_mode_easy:=false


var stock_cards:ClassCardStack=ClassCardStack.new()
var waste_cards:ClassCardStack=ClassCardStack.new()

func get_card_back():
	if _is_game_mode_easy:
		return CARD_BACK_BLUE
	else :
		return CARD_BACK_RED
