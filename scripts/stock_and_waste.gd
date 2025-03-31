extends HBoxContainer
@onready var stock: Control = $Stock
@onready var waste: Control = $Waste

var waste_cards= GameData.get_waste_stack()

func _ready() -> void:
	pass

func reset_stock(cards:ClassCardStack):
	stock.reset(cards)

func _on_stock_stock_card_popped(card: ClassCard) -> void:
	card.is_flipped=false
	waste.add_card(card)


func _on_stock_stock_to_shuffle() -> void:
	if not waste_cards.is_empty():
		stock.disable_button(true)
		var new_stock_cards = ClassCardStack.shuffle(waste_cards)
		waste.shuffle()
		#等待第一张牌从废牌堆到牌库
		await get_tree().create_timer(GameSettings.WASTE_TO_STOCK_DURATION+GameSettings.WASTE_TO_STOCK_DELAY).timeout
		stock.reset(new_stock_cards)
		await waste.shuffle_finished
		stock.disable_button(false)
		
