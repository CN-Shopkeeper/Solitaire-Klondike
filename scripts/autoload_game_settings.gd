extends Node

const CARD_BACK_BLUE = preload("res://asserts/cards/card_back_blue.png")
const CARD_BACK_RED = preload("res://asserts/cards/card_back_red.png")
const CARD = preload("res://scenes/card.tscn")

const STOCK_TO_WASTE_DURATION=0.1
const WASTE_TO_STOCK_DURATION=0.05
const WASTE_TO_STOCK_DELAY = 0.02

const WAST_PILE_OFFSET_X=20.0

const RED_SUITS=["hearts","diamonds"]
const BLACK_SUITS=["clubs","spades"]
const POINTS=['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K']

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

func get_tableau_card_nodes(group_index:int):
	return get_tree().get_nodes_in_group("tableau_%s_cards"%str(group_index))

func add_tableau_card_node(group_index:int,card:ClassCard):
	var card_nodes = get_tree().root.get_node("Main/Cards")
	var node = CARD.instantiate()
	card_nodes.add_child(node)
	node.add_to_group("tableau_%s_cards"%str(group_index))
	node.set_card(card)
	return node

# 检查是否能移动到目标牌
func check_card_move_legal(card_source:ClassCard,card_target:ClassCard):
	var point_index_s =POINTS.find(card_source.point)
	var point_index_t =POINTS.find(card_target.point)
	if point_index_s==-1 or point_index_t==-1:
		return false
	return (point_index_s==point_index_t-1) and ((card_source.suit in RED_SUITS and card_target.suit in BLACK_SUITS) or (card_source.suit in BLACK_SUITS and card_target.suit in RED_SUITS))

# 移动一个牌到目标牌牌堆
func move_card_to_tableau(card_source_node:Control,card_target_node:Control):
	
	var source_node_group = card_source_node.get_groups()[0]
	var target_node_group = card_target_node.get_groups()[0]
	var source_stack=_get_stack_from_group(source_node_group)
	var target_stack = _get_stack_from_group(target_node_group)
	if !source_stack or !target_stack:
		return
	card_source_node.remove_from_group(card_source_node.get_groups()[0])
	card_source_node.add_to_group(card_target_node.get_groups()[0])
	# stack的修改要在node之后，因为stack有信号
	target_stack.push(source_stack.pop())
	
func get_card_back():
	if _is_game_mode_easy:
		return CARD_BACK_BLUE
	else :
		return CARD_BACK_RED

func _get_stack_from_group(group:String)->ClassCardStack:
	# 匹配tableau组
	if group.begins_with("tableau_"):
		var digit = group.replace("tableau_", "").replace("_cards", "")
		return tableau_cards[int(digit)]
	if group=="waste_cards":
				return waste_cards
	return null
	
