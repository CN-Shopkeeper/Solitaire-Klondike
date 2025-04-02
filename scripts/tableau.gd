extends Control
@export var group_index: int


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
	cards.assign(new_cards)
	var index = 0
	for card in cards.get_stack_array():
		# 生成最新的卡牌
		var node = CardNodeManager.create_tableau_card_node(card, group_index)

		var position := global_position + Vector2(0.0, index * pile_offset_y)
		node.position = position
		node.legal_position = position
		index += 1
	cards.peek().is_flipped = false

func _rearrange():
	var card_nodes = CardNodeManager.get_tableau_card_nodes(group_index)

	var index = 0
	for node in card_nodes:
		var position := global_position + Vector2(0.0, index * pile_offset_y)
		node.legal_position = position
		node.tween_to_legal_position()
		index += 1

	# 尝试将最上面一张翻开
	if card_nodes.size() > 0:
		card_nodes[-1].card.is_flipped = false
