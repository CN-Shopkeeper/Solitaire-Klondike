extends Control

signal shuffle_finished

@export var cards_control: Control

const STOCK_OFFSET := Vector2(-112.0, 0)

var waste_cards = GameData.get_waste_stack()

var stock_position: Vector2:
	get:
		return STOCK_OFFSET + global_position

func _ready() -> void:
	waste_cards.connect("item_changed", Callable(self, "_rearrange"))

func _rearrange():
	var cards_displayed = CardNodeManager.get_waste_card_nodes()
	for card in cards_displayed:
		card.card.is_flipped = false
	#for i in range(cards_displayed.size()):
		#cards_displayed[i].z_index = i
	if cards_displayed.size() >= 3:
		# 这里简化逻辑，只需要移动当前的倒数一二三张
		# 移动后面三张卡牌
		_move_card(cards_displayed[-3], 0, cards_displayed[-3].position)
		_move_card(cards_displayed[-2], 1, cards_displayed[-2].position)
		_move_card(cards_displayed[-1], 2, cards_displayed[-1].position)
	elif cards_displayed.size() == 2:
		_move_card(cards_displayed[-2], 0, cards_displayed[-2].position)
		_move_card(cards_displayed[-1], 1, cards_displayed[-1].position)
	elif cards_displayed.size() == 1:
		_move_card(cards_displayed[0], 0, cards_displayed[0].position)


func _move_card(card, to_index: int, from_pos):
	var final_pos = global_position + Vector2(GameSettings.WAST_PILE_OFFSET_X * to_index, 0.0)
	card.legal_position = final_pos
	return card.tween_to_legal_position(GameSettings.STOCK_TO_WASTE_DURATION)
