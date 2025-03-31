extends Node

# todo: 重构这个类，分为：setting、game rules、node

const CARD_BACK_BLUE = preload("res://asserts/cards/card_back_blue.png")
const CARD_BACK_RED = preload("res://asserts/cards/card_back_red.png")
const CARD = preload("res://scenes/card.tscn")

const STOCK_TO_WASTE_DURATION=0.1
const WASTE_TO_STOCK_DURATION=0.05
const WASTE_TO_STOCK_DELAY = 0.02

const WAST_PILE_OFFSET_X=20.0

const SUITS=["diamonds","clubs","hearts","spades"]
const RED_SUITS=["hearts","diamonds"]
const BLACK_SUITS=["clubs","spades"]
const POINTS=['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K']

var _is_game_mode_easy:=false


var stock_cards:ClassCardStack=ClassCardStack.new()
var waste_cards:ClassCardStack=ClassCardStack.new()
var tableau_cards: Array[ClassCardStack] = []
var foundation_cards: Array[ClassCardStack] = []

func _ready() -> void:
	for i in range(7):
		tableau_cards.append(ClassCardStack.new())
	for i in range(4):
		foundation_cards.append(ClassCardStack.new())

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

func get_foundation_card_nodes(suit:String):
	return get_tree().get_nodes_in_group("foundation_%s_cards"%suit)


# 检查是否能移动到目标牌
func check_card_move_legal(card_source:ClassCard,card_target:ClassCard)->bool:
	var point_index_s =POINTS.find(card_source.point)
	var point_index_t =POINTS.find(card_target.point)
	if point_index_s==-1 or point_index_t==-1:
		return false
	return (point_index_s==point_index_t-1) and ((card_source.suit in RED_SUITS and card_target.suit in BLACK_SUITS) or (card_source.suit in BLACK_SUITS and card_target.suit in RED_SUITS))

# todo: 胜利条件判定，放在signal中做
func check_card_move_foundation_legal(card_source:ClassCard,target_foundation_suit:String)->bool:
	print(card_source.point,card_source.suit,target_foundation_suit)
	# 花色判断
	if card_source.suit!=target_foundation_suit:
		return false
	var target_stack = get_foundation_stack(target_foundation_suit)
	# 如果当前foundation已完成，则直接判错
	if target_stack.size()>13:
		return false
	var source_point_index = POINTS.find(card_source.point)
	# 如果当前foundation为空，则点数必须为A（index=0）
	if target_stack.size()==0:
		print(target_stack.size(),source_point_index)
		return source_point_index==0
	# 否则，foundation的peek的点数必须等于source点数-1
	return POINTS.find(target_stack.peek().point)==source_point_index-1

# 移动一个牌(组)到目标牌牌堆
func move_cards_to_tableau(card_source_node_root:Control,card_target_node:Control):
	var source_group=_get_group_from_node(card_source_node_root)
	var target_group = _get_group_from_node(card_target_node)
	if !source_group or !target_group:
		return
	var source_stack=_get_stack_from_group(source_group)
	var target_stack = _get_stack_from_group(target_group)
	if !source_stack or !target_stack:
		return
	var nodes_to_move= find_ordering_card_nodes(card_source_node_root)

	for node in nodes_to_move:
		node.remove_from_group(source_group)
		node.add_to_group(target_group)
	# stack的修改要在node之后，因为stack有信号
	target_stack.push_n(source_stack.pop_n(nodes_to_move.size()))

# 将一个牌移动到foundation
func move_card_to_foundation(card_node:Control,suit:String):
	var source_group=_get_group_from_node(card_node)
	if !source_group:
		return
	var foundation_stack=get_foundation_stack(suit)
	var source_stack = _get_stack_from_group(source_group)
	if !source_stack or !foundation_stack:
		return
	card_node.remove_from_group(source_group)
	
	card_node.add_to_group("foundation_%s_cards"%suit)
	
	# stack的修改要在node之后，因为stack有信号
	# 从tableau移动到foundation的card一定是处于顶部
	foundation_stack.push(source_stack.pop())


func find_ordering_card_nodes(root_card_node:Control)->Array:
	var card_stack = _get_stack_from_group(_get_group_from_node(root_card_node))
	if not card_stack:
		return [root_card_node]
	var to_move_cards=card_stack.find_first_and_get_sublist(root_card_node.card)
	return to_move_cards.map(func(card):return card.owning_node.get_ref())

func create_move_group_tmp(root_card_node:Control):
	var card_stack = _get_stack_from_group(_get_group_from_node(root_card_node))
	if !card_stack:
		# 未找到stack，说明该card可能是单独运行的场景
		root_card_node.add_to_group("move_group_tmp")
		return
	var to_move_cards=card_stack.find_first_and_get_sublist(root_card_node.card)
	for card in to_move_cards:
		var card_node = card.owning_node.get_ref()
		if card_node:
			card_node.add_to_group("move_group_tmp")

func delete_move_group_tmp():
	var card_nodes= get_tree().get_nodes_in_group("move_group_tmp")
	for node in card_nodes:
		node.remove_from_group("move_group_tmp")


func get_card_back():
	if _is_game_mode_easy:
		return CARD_BACK_BLUE
	else :
		return CARD_BACK_RED

func _get_group_from_node(card_node:Control)->String:
	var node_groups = card_node.get_groups()
	var matched_group:String
	for group in node_groups:
		if group.contains("cards"):
			matched_group=group
			break
	return matched_group

func _get_stack_from_group(group:String)->ClassCardStack:
	if !group:
		return null
	# 匹配tableau组
	if group.begins_with("tableau_"):
		var digit = group.replace("tableau_", "").replace("_cards", "")
		return tableau_cards[int(digit)]
	if group=="waste_cards":
				return waste_cards
	return null

func get_foundation_stack(suit:String):
	return foundation_cards[SUITS.find(suit)]
