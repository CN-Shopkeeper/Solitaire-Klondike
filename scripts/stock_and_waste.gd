extends HBoxContainer
@onready var stock: Control = $Stock
@onready var waste: Control = $Waste

# cards node的父节点
@export var cards_control: Control

var stock_cards = GameData.get_stock_stack()
var waste_cards = GameData.get_waste_stack()

func _ready() -> void:
	waste.cards_control = cards_control
	pass

func reset_stock(new_stock_cards: ClassCardStack):
	new_stock_cards = new_stock_cards.get_copy()
	for card in new_stock_cards.get_stack_array():
		# 生成最新的卡牌
		CardNodeManager.create_stock_card_node(card, cards_control)

	stock_cards.assign(new_stock_cards)

func _on_stock_stock_pressed() -> void:
	if stock_cards.is_empty():
		# 如果牌库为空，则从废牌堆重置牌库

		# 如果废牌堆也为空，则什么都不做
		if waste_cards.is_empty():
			return

		GameSettings.save_state()
		stock.disable_button(true)
		while not waste_cards.is_empty():
			CardNodeManager.move_card_from_waste_to_stock()
			# 每张牌的重置间隔
			#await get_tree().create_timer(GameSettings.WASTE_TO_STOCK_DELAY).timeout
		stock_cards.shuffle()
		# 等待洗牌动画完成
		var waiting_time = GameSettings.WASTE_TO_STOCK_DURATION + GameSettings.WASTE_TO_STOCK_DELAY * stock_cards.size()
		await get_tree().create_timer(waiting_time).timeout
		stock.disable_button(false)
	else:
		# 否则从牌库取出一张牌到废牌堆
		GameSettings.save_state()
		CardNodeManager.move_card_from_stock_to_waste()
