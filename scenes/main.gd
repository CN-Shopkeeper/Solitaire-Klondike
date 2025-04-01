extends Control
@onready var tableau_group: HBoxContainer = $CenterContainer/MarginContainer/Tableau_group
@onready var stock_and_waste: HBoxContainer = $CenterContainer/CardTable/HBoxContainer/StockAndWaste

func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	var dealt_cards = GameRules.deal()
	for i in range(7):
		tableau_group.get_child(i).reset(dealt_cards[i])
	stock_and_waste.reset_stock(dealt_cards[7])

	GameRules.connect("win", Callable(self, "_win"))

func _win():
	$Label.text = "you win"
