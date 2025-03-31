extends HBoxContainer
@onready var stock: Control = $Stock
@onready var waste: Control = $Waste

func _ready() -> void:
	var stock_cards:=ClassCardStack.new()
	var cards:Array[ClassCard]=[]
	var suits=["hearts","clubs","diamonds","spades"]
	var index=0
	var points=['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K']
	points.reverse()
	for point in points:
		cards.append(ClassCard.new(suits[index],point))
		index+=1
		index%=4
	stock_cards.push_n(cards)
	stock.reset(stock_cards)

func _on_stock_stock_card_popped(card: ClassCard) -> void:
	card.is_flipped=false
	waste.add_card(card)


func _on_stock_stock_to_shuffle() -> void:
	if not GameSettings.waste_cards.is_empty():
		stock.disable_button(true)
		var new_stock_cards = ClassCardStack.shuffle(GameSettings.waste_cards)
		waste.shuffle()
		#等待第一张牌从废牌堆到牌库
		await get_tree().create_timer(GameSettings.WASTE_TO_STOCK_DURATION+GameSettings.WASTE_TO_STOCK_DELAY).timeout
		stock.reset(new_stock_cards)
		await waste.shuffle_finished
		stock.disable_button(false)
		
