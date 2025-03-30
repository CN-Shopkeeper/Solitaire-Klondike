extends Node

const CARD_BACK_BLUE = preload("res://asserts/cards/card_back_blue.png")
const CARD_BACK_RED = preload("res://asserts/cards/card_back_red.png")
const CARD = preload("res://scenes/card.tscn")

const STOCK_TO_WASTE_DURATION=0.1
const WASTE_TO_STOCK_DURATION=0.05
const WASTE_TO_STOCK_DELAY = 0.02

const WAST_PILE_OFFSET_X=20.0

var _is_game_mode_easy:=false


var stock_cards:ClassCardStack=ClassCardStack.new()
var waste_cards:ClassCardStack=ClassCardStack.new()
var tableau_cards: Array[ClassCardStack] = []

func _ready() -> void:
	for i in range(7):
		tableau_cards.append(ClassCardStack.new())

func get_waste_card_nodes():
	return get_tree().get_nodes_in_group("waste_cards")

func add_waste_card_node(card:ClassCard):
	var card_nodes = get_tree().root.get_node("Main/Cards")
	var node = CARD.instantiate()
	card_nodes.add_child(node)
	node.add_to_group("waste_cards")
	node.set_card(card)
	return node
	

func add_tableau_card_node(group_index:int,card:ClassCard):
	var card_nodes = get_tree().root.get_node("Main/Cards")
	var node = CARD.instantiate()
	card_nodes.add_child(node)
	node.add_to_group("tableaus_%s_card"%str(group_index))
	node.set_card(card)
	return node


func get_card_back():
	if _is_game_mode_easy:
		return CARD_BACK_BLUE
	else :
		return CARD_BACK_RED
