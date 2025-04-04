extends Node
const CARD = preload("res://scenes/card.tscn")

const TEMP_MOVE_GROUP_NAME = "move_group_tmp"
const TIPS_GROUP_NAME = "tips_group"

# 开始游戏时，先将所有card节点删除
func delete_all_card_nodes(cards_control: Control = null):
	if !cards_control:
		# 如果缺省，则默认从主场景中加载
		cards_control = get_tree().root.get_node("Main/Cards")
	for card_node in cards_control.get_children():
		card_node.queue_free()


# 创建card节点并添加到组
func create_card_node(card: ClassCard, cards_control: Control):
	if !cards_control:
		# 如果缺省，则默认从主场景中加载
		cards_control = get_tree().root.get_node("Main/Cards")
	var node = CARD.instantiate()
	cards_control.add_child(node)
	node.set_card(card)
	return node

func create_stock_card_node(card: ClassCard, cards_control: Control = null):
	return create_card_node(card, cards_control)

func create_waste_card_node(card: ClassCard, cards_control: Control = null):
	return create_card_node(card, cards_control)

func create_tableau_card_node(card: ClassCard, group_index: int, cards_control: Control = null):
	return create_card_node(card, cards_control)

func get_stock_card_nodes():
	var nodes = []
	for stock_card in GameData.get_stock_stack().get_stack_array():
		var node = stock_card.get_owning_node()
		nodes.append(node)
		node.get_parent().move_child(node, -1)
	return nodes

func get_waste_card_nodes():
	var nodes = []
	for waste_card in GameData.get_waste_stack().get_stack_array():
		var node = waste_card.get_owning_node()
		nodes.append(waste_card.get_owning_node())
		node.get_parent().move_child(node, -1)
	return nodes

func get_tableau_card_nodes(group_index: int):
	var nodes = []
	for tableau_card in GameData.get_tableau_stack(group_index).get_stack_array():
		var node = tableau_card.get_owning_node()
		nodes.append(tableau_card.get_owning_node())
		node.get_parent().move_child(node, -1)
	return nodes

func get_foundation_card_nodes(suit: String):
	var nodes = []
	for foundation_card in GameData.get_foundation_stack(suit).get_stack_array():
		var node = foundation_card.get_owning_node()
		nodes.append(foundation_card.get_owning_node())
		node.get_parent().move_child(node, -1)
	return nodes

func get_test_card_nodes(test_stack_name: String):
	var nodes = []
	for stock_card in GameData.get_test_cards(test_stack_name).get_stack_array():
		var node = stock_card.get_owning_node()
		nodes.append(node)
		node.get_parent().move_child(node, -1)
	return nodes

# 移动stock顶部的牌到waste
func move_card_from_stock_to_waste():
	if GameData.get_stock_stack().size() == 0:
		return

	var source_stack = GameData.get_stock_stack()
	var target_stack = GameData.get_waste_stack()

	var card = source_stack.pop()
	var card_node = card.owning_node.get_ref()

	# 在场景树中移动到最上方
	card_node.get_parent().move_child(card_node, -1)

	# stack的修改要在node之后，因为stack有信号
	target_stack.push(card)
	return card_node

# 移动waste顶部的牌到stock，一张一张移动，因为要处理动画
func move_card_from_waste_to_stock():
	if GameData.get_waste_stack().size() == 0:
		return

	var card = GameData.get_waste_stack().pop()
	var card_node = card.owning_node.get_ref()

	# 在场景树中移动到最上方
	card_node.get_parent().move_child(card_node, -1)

	# stack的修改要在node之后，因为stack有信号
	GameData.get_stock_stack().push(card)
	return card_node

# 移动一个牌(组)到目标牌牌堆
func move_card_nodes_to_tableau(card_source_node_root: Control, card_target_node: Control):
	var source_stack = GameData.get_card_stack(card_source_node_root.card)
	var target_stack = GameData.get_card_stack(card_target_node.card)
	if !source_stack or !target_stack:
		return
	var nodes_to_move = find_ordering_card_nodes(card_source_node_root)

	for node in nodes_to_move:

		# 在场景树中移动到最上方
		node.get_parent().move_child(node, -1)

	# stack的修改要在node之后，因为stack有信号
	target_stack.push_n(source_stack.pop_n(nodes_to_move.size()))

# 移动一个牌(组)到目标牌牌堆
func move_card_nodes_to_tableau_bottom(card_source_node_root: Control, tableau_index: int):
	var source_stack = GameData.get_card_stack(card_source_node_root.card)
	var target_stack = GameData.get_tableau_stack(tableau_index)
	if !source_stack or !target_stack:
		return
	var nodes_to_move = find_ordering_card_nodes(card_source_node_root)

	for node in nodes_to_move:
		# 在场景树中移动到最上方
		node.get_parent().move_child(node, -1)

	# stack的修改要在node之后，因为stack有信号
	target_stack.push_n(source_stack.pop_n(nodes_to_move.size()))


# 将一个牌移动到foundation
func move_card_node_to_foundation(card_node: Control, suit: String):
	var foundation_stack = GameData.get_foundation_stack(suit)
	var source_stack = GameData.get_card_stack(card_node.card)
	if !source_stack or !foundation_stack:
		return

	# stack的修改要在node之后，因为stack有信号
	# 从tableau移动到foundation的card一定是处于顶部
	foundation_stack.push(source_stack.pop())

func create_tips_cards_node_and_tween(cards: Array, from_pos: Vector2, to_pos: Vector2, offset: Vector2, cards_control: Control):
	var card_nodes = []
	for i in cards.size():
		var card = cards[i]
		var tips_card_node = create_card_node(card, cards_control)
		# 为什么这里设置tips_card_node.shadow.hide无效
		tips_card_node.position = from_pos + offset * i
		tips_card_node.add_to_group(TIPS_GROUP_NAME)
		card_nodes.append(tips_card_node)
	# to_pos: Vector2, duration: float, from_pos: Vector2 = Vector2.ZERO, delay = 0.0
	var tips_loop_cnt = 3
	var looping = true
	while tips_loop_cnt > 0:
		for i in card_nodes.size():
			var tips_card_node = card_nodes[i]
			if tips_card_node:
				tips_card_node.tween_position(to_pos + offset * i, GameSettings.TIPS_CARD_DURATION, from_pos + offset * i)
			else:
				looping = false
				break
		if not looping:
			break
		await get_tree().create_timer(GameSettings.TIPS_CARD_DURATION + 0.5).timeout
		tips_loop_cnt -= 1
	for tips_card_node in card_nodes:
		if tips_card_node:
			tips_card_node.queue_free()

func create_tips_card_back_node_and_tween_scale(pos: Vector2, cards_control: Control):
	var tips_card_node = create_card_node(ClassCard.new(Poker.HEARTS, "A"), cards_control)
	tips_card_node.position = pos
	tips_card_node.add_to_group(TIPS_GROUP_NAME)
	var tween = create_tween()
	var tips_loop_cnt = 3
	var looping = true
	while tips_loop_cnt > 0:
		if tips_card_node:
			tween.kill()
			tween = create_tween()
			tween.tween_property(tips_card_node, "scale", Vector2(1.1, 1.1), 0.3) \
				.set_trans(Tween.TRANS_QUAD) \
				.set_ease(Tween.EASE_OUT)

		# 第二个动画：从1.1回到1
			tween.tween_property(tips_card_node, "scale", Vector2(1.0, 1.0), 0.3) \
				.set_trans(Tween.TRANS_QUAD) \
				.set_ease(Tween.EASE_IN)
		else:
			looping = false
			break
		if not looping:
			break
		await get_tree().create_timer(0.6 + 0.5).timeout
		tips_loop_cnt -= 1

	if tips_card_node:
			tips_card_node.queue_free()

func remove_tips_card_node():
	var tips_nodes = get_tree().get_nodes_in_group(TIPS_GROUP_NAME)
	for node in tips_nodes:
		if node:
			node.queue_free()

# 获取当前节点的card及其顺序下的card的nodes
func find_ordering_card_nodes(root_card_node: Control) -> Array:
	var card_stack = GameData.get_card_stack(root_card_node.card)
	if not card_stack:
		return [root_card_node]
	var to_move_cards = card_stack.find_first_and_get_sublist(root_card_node.card)
	return to_move_cards.map(func(card): return card.owning_node.get_ref())

func create_move_group_tmp(root_card_node: Control):
	var card_stack = GameData.get_card_stack(root_card_node.card)
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
