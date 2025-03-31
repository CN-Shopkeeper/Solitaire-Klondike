extends Control
@onready var label: Label = $Label

@export var suit:String
@export var suit_color:Color

var cards:ClassCardStack:
	get:
		return GameSettings.get_foundation_stack(suit)


const suit_symbols = {
	"diamonds":"♦",
	"clubs":"♣",
	"hearts":"♥",
	"spades":"♠"
}

func _ready() -> void:
	$Area2D.add_to_group("foundation_area")
	label.text=suit_symbols.get(suit)
	label.add_theme_color_override("font_color", suit_color)
	cards.connect("item_changed",Callable(self,"_rearrange"))

func _rearrange():
	var card_nodes = GameSettings.get_foundation_card_nodes(suit)
	
	var position:=global_position
	for node in card_nodes:
		node.card.is_completed=true
		node.legal_position=position
		node.tween_to_legal_position()
	
