extends Control
@onready var texture_button: TextureButton = $TextureButton

signal stock_pressed

var stock_cards = GameData.get_stock_stack()

func _ready() -> void:
	stock_cards.connect("item_changed", _rearrange)
	call_deferred("_make_texture_button_top_level")


func disable_button(disabled: bool):
	texture_button.disabled = disabled

func _make_texture_button_top_level():
	texture_button.top_level = true
	# 对top level的元素赋值位置
	texture_button.position = global_position

func _rearrange():
	texture_button.set_texture_normal(GameSettings.get_card_back())
	if stock_cards.size() > 0:
		texture_button.set_self_modulate(Color(1, 1, 1, 1))
	else:
		texture_button.set_self_modulate(Color(1, 1, 1, 0.2))

	var card_nodes = CardNodeManager.get_stock_card_nodes()

	var parent_position = global_position
	var delay_index = 0
	for node in card_nodes:
		node.legal_position = parent_position
		if node.position != node.legal_position:
			var tween_move = node.tween_to_legal_position(GameSettings.WASTE_TO_STOCK_DURATION, GameSettings.WASTE_TO_STOCK_DELAY * delay_index)
			tween_move.finished.connect(func():
				node.play_audio_shuffle()
				# 所有牌翻面
				node.card.is_flipped = true
			)

			delay_index += 1



func _on_texture_button_pressed() -> void:
	emit_signal("stock_pressed")
