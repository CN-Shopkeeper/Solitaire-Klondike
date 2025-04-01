extends Node

# todo: 重构这个类，分为：setting、game rules、node

const CARD_BACK_BLUE = preload("res://asserts/cards/card_back_blue.png")
const CARD_BACK_RED = preload("res://asserts/cards/card_back_red.png")
const CARD = preload("res://scenes/card.tscn")

const STOCK_TO_WASTE_DURATION = 0.1
const WASTE_TO_STOCK_DURATION = 0.05
const WASTE_TO_STOCK_DELAY = 0.02

const WAST_PILE_OFFSET_X = 20.0

var playing := false
var _is_game_mode_easy := true

func change_difficulty():
	_is_game_mode_easy = !_is_game_mode_easy
	return _is_game_mode_easy


func get_waste_card_nodes():
	return get_tree().get_nodes_in_group("waste_cards")

func add_waste_card_node(card: ClassCard):
	var card_nodes = get_tree().root.get_node("Main/Cards")
	var node = CARD.instantiate()
	card_nodes.add_child(node)
	node.add_to_group("waste_cards")
	node.set_card(card)
	return node

func get_tableau_card_nodes(group_index: int):
	return get_tree().get_nodes_in_group("tableau_%s_cards"%str(group_index))

func add_tableau_card_node(group_index: int, card: ClassCard):
	var card_nodes = get_tree().root.get_node("Main/Cards")
	var node = CARD.instantiate()
	card_nodes.add_child(node)
	node.add_to_group("tableau_%s_cards"%str(group_index))
	node.set_card(card)
	return node

func get_foundation_card_nodes(suit: String):
	return get_tree().get_nodes_in_group("foundation_%s_cards"%suit)



# 移动一个牌(组)到目标牌牌堆
func move_cards_to_tableau_card(card_source_node_root: Control, card_target_node: Control):
	var source_group = _get_group_from_node(card_source_node_root)
	var target_group = _get_group_from_node(card_target_node)
	if !source_group or !target_group:
		return
	var source_stack = GameData.get_stack_from_group(source_group)
	var target_stack = GameData.get_stack_from_group(target_group)
	if !source_stack or !target_stack:
		return
	var nodes_to_move = find_ordering_card_nodes(card_source_node_root)

	for node in nodes_to_move:
		node.remove_from_group(source_group)
		node.add_to_group(target_group)
	# stack的修改要在node之后，因为stack有信号
	target_stack.push_n(source_stack.pop_n(nodes_to_move.size()))

# 移动一个牌(组)到目标牌牌堆
func move_cards_to_tableau_bottom(card_source_node_root: Control, tableau_index: int):
	var source_group = _get_group_from_node(card_source_node_root)
	var target_group = "tableau_%s_cards"%str(tableau_index)
	if !source_group or !target_group:
		return
	var source_stack = GameData.get_stack_from_group(source_group)
	var target_stack = GameData.get_stack_from_group(target_group)
	if !source_stack or !target_stack:
		return
	var nodes_to_move = find_ordering_card_nodes(card_source_node_root)

	for node in nodes_to_move:
		node.remove_from_group(source_group)
		node.add_to_group(target_group)
	# stack的修改要在node之后，因为stack有信号
	target_stack.push_n(source_stack.pop_n(nodes_to_move.size()))


# 将一个牌移动到foundation
func move_card_to_foundation(card_node: Control, suit: String):
	var source_group = _get_group_from_node(card_node)
	if !source_group:
		return
	var foundation_stack = GameData.get_foundation_stack(suit)
	var source_stack = GameData.get_stack_from_group(source_group)
	if !source_stack or !foundation_stack:
		return
	card_node.remove_from_group(source_group)

	card_node.add_to_group("foundation_%s_cards"%suit)

	# stack的修改要在node之后，因为stack有信号
	# 从tableau移动到foundation的card一定是处于顶部
	foundation_stack.push(source_stack.pop())


func find_ordering_card_nodes(root_card_node: Control) -> Array:
	var card_stack = GameData.get_stack_from_group(_get_group_from_node(root_card_node))
	if not card_stack:
		return [root_card_node]
	var to_move_cards = card_stack.find_first_and_get_sublist(root_card_node.card)
	return to_move_cards.map(func(card): return card.owning_node.get_ref())

func create_move_group_tmp(root_card_node: Control):
	var card_stack = GameData.get_stack_from_group(_get_group_from_node(root_card_node))
	if !card_stack:
		# 未找到stack，说明该card可能是单独运行的场景
		root_card_node.add_to_group("move_group_tmp")
		return
	var to_move_cards = card_stack.find_first_and_get_sublist(root_card_node.card)
	for card in to_move_cards:
		var card_node = card.owning_node.get_ref()
		if card_node:
			card_node.add_to_group("move_group_tmp")

func delete_move_group_tmp():
	var card_nodes = get_tree().get_nodes_in_group("move_group_tmp")
	for node in card_nodes:
		node.remove_from_group("move_group_tmp")


func get_card_back():
	if _is_game_mode_easy:
		return CARD_BACK_BLUE
	else:
		return CARD_BACK_RED

func _get_group_from_node(card_node: Control) -> String:
	var node_groups = card_node.get_groups()
	var matched_group: String
	for group in node_groups:
		if group.contains("cards"):
			matched_group = group
			break
	return matched_group
