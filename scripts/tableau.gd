extends Control
@export var group_index: int
# cards node的父节点
@export var cards_control: Control

var cards: ClassCardStack:
	get:
		return GameData.get_tableau_stack(group_index)


var pile_offset_y: float:
	get:
		if cards.size() < 10:
			return 20
		else:
			return 20- cards.size() + 10

func _ready() -> void:
	$Area2D.add_to_group("tableau_area")

	cards.connect("item_changed", Callable(self, "_rearrange"))

func reset(new_cards: ClassCardStack) -> void:
	# 防止从外部修改
	new_cards = new_cards.get_copy()
	for card in new_cards.get_stack_array():
		# 生成最新的卡牌
		CardNodeManager.create_card_node(card, GameSettings.card_node_init_pos, cards_control)

	cards.assign(new_cards)
	cards.peek().is_flipped = false

func _rearrange():
	var card_nodes = CardNodeManager.get_tableau_card_nodes(group_index)

	var index = 0
	for node in card_nodes:
		var legal_position := global_position + Vector2(0.0, index * pile_offset_y)
		node.legal_position = legal_position
		if node.position != node.legal_position:
			node.tween_to_legal_position()
		index += 1

	# 尝试将最上面一张翻开
	if card_nodes.size() > 0:
		card_nodes[-1].card.is_flipped = false
