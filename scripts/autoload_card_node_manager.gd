extends Node
const CARD = preload("res://scenes/card.tscn")

const WASTE_CARD_NODE_GROUP_NAME = "waste_cards"
const STOCK_CARD_NODE_GROUP_NAME = "stock_cards"
const TABLEAU_CARD_NODE_GROUP_NAME_TEMPLATE = "tableau_%s_cards"
const FOUNDATION_CARD_NODE_GROUP_NAME_TEMPLATE = "foundation_%s_cards"

const TEMP_MOVE_GROUP_NAME = "move_group_tmp"

# 创建card节点并添加到组
func create_card_node(card: ClassCard, group_name: String, cards_control: Control):
	if !cards_control:
		# 如果缺省，则默认从主场景中加载
		cards_control = get_tree().root.get_node("Main/Cards")
	var node = CARD.instantiate()
	cards_control.add_child(node)
	node.add_to_group(group_name)
	node.set_card(card)
	return node

func create_stock_card_node(card: ClassCard, cards_control: Control = null):
	return create_card_node(card, STOCK_CARD_NODE_GROUP_NAME, cards_control)

func create_waste_card_node(card: ClassCard, cards_control: Control = null):
	return create_card_node(card, WASTE_CARD_NODE_GROUP_NAME, cards_control)

func create_tableau_card_node(card: ClassCard, group_index: int, cards_control: Control = null):
	return create_card_node(card, TABLEAU_CARD_NODE_GROUP_NAME_TEMPLATE %str(group_index), cards_control)

# 根据组来获取card节点
func get_card_nodes_by_group(group_name: String):
	return get_tree().get_nodes_in_group(group_name)

func get_stock_card_nodes():
	return get_card_nodes_by_group(STOCK_CARD_NODE_GROUP_NAME)

func get_waste_card_nodes():
	return get_card_nodes_by_group(WASTE_CARD_NODE_GROUP_NAME)

func get_tableau_card_nodes(group_index: int):
	return get_card_nodes_by_group(TABLEAU_CARD_NODE_GROUP_NAME_TEMPLATE %str(group_index))

func get_foundation_card_nodes(suit: String):
	return get_card_nodes_by_group(FOUNDATION_CARD_NODE_GROUP_NAME_TEMPLATE %suit)


# 移动stock顶部的牌到waste
func move_card_from_stock_to_waste():
	if GameData.get_stock_stack().size() == 0:
		return

	var source_stack = GameData.get_stock_stack()
	var target_stack = GameData.get_waste_stack()

	var card = source_stack.pop()
	var card_node = card.owning_node.get_ref()
	card_node.remove_from_group(STOCK_CARD_NODE_GROUP_NAME)
	card_node.add_to_group(WASTE_CARD_NODE_GROUP_NAME)

	# 在场景树中移动到最上方
	card_node.get_parent().move_child(card_node, -1)

	# stack的修改要在node之后，因为stack有信号
	target_stack.push(card)

# 移动waste顶部的牌到stock，一张一张移动，因为要处理动画
func move_card_from_waste_to_stock():
	if GameData.get_waste_stack().size() == 0:
		return

	var card = GameData.get_waste_stack().pop()
	var card_node = card.owning_node.get_ref()
	card_node.remove_from_group(WASTE_CARD_NODE_GROUP_NAME)
	card_node.add_to_group(STOCK_CARD_NODE_GROUP_NAME)

	# 在场景树中移动到最上方
	card_node.get_parent().move_child(card_node, -1)

	# stack的修改要在node之后，因为stack有信号
	GameData.get_stock_stack().push(card)

# 移动一个牌(组)到目标牌牌堆
func move_card_nodes_to_tableau(card_source_node_root: Control, card_target_node: Control):
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

		# 在场景树中移动到最上方
		node.get_parent().move_child(node, -1)

	# stack的修改要在node之后，因为stack有信号
	target_stack.push_n(source_stack.pop_n(nodes_to_move.size()))

# 移动一个牌(组)到目标牌牌堆
func move_card_nodes_to_tableau_bottom(card_source_node_root: Control, tableau_index: int):
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

		# 在场景树中移动到最上方
		node.get_parent().move_child(node, -1)

	# stack的修改要在node之后，因为stack有信号
	target_stack.push_n(source_stack.pop_n(nodes_to_move.size()))


# 将一个牌移动到foundation
func move_card_node_to_foundation(card_node: Control, suit: String):
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

# 获取当前节点的card及其顺序下的card的nodes
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
		root_card_node.add_to_group(TEMP_MOVE_GROUP_NAME)
		return
	var to_move_cards = card_stack.find_first_and_get_sublist(root_card_node.card)
	for card in to_move_cards:
		var card_node = card.owning_node.get_ref()
		if card_node:
			card_node.add_to_group(TEMP_MOVE_GROUP_NAME)

func delete_move_group_tmp():
	var card_nodes = get_tree().get_nodes_in_group(TEMP_MOVE_GROUP_NAME)
	for node in card_nodes:
		node.remove_from_group(TEMP_MOVE_GROUP_NAME)


func _get_group_from_node(card_node: Control) -> String:
	var node_groups = card_node.get_groups()
	var matched_group: String
	for group in node_groups:
		if group.contains("cards"):
			matched_group = group
			break
	return matched_group
