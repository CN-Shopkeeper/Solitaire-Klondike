extends Control
@onready var texture_button: TextureButton = $TextureButton

signal stock_card_popped(card:ClassCard)
signal stock_to_shuffle
	

func _process(delta: float) -> void:	
	pass
		
func reset(new_stock_cards:ClassCardStack)->void:
	GameSettings.stock_cards.assign(new_stock_cards)
	_update_texture()

func disable_button(disabled:bool):
	texture_button.disabled=disabled

func _update_texture():
	texture_button.set_texture_normal(GameSettings.get_card_back())
	if GameSettings.stock_cards.size()>0:
		texture_button.set_self_modulate(Color(1,1,1,1))
	else:
		texture_button.set_self_modulate(Color(1,1,1,0.2))
	

func _on_texture_button_pressed() -> void:
	if GameSettings.stock_cards.is_empty():
		# 如果牌库为空，则从废牌堆重置牌库
		emit_signal("stock_to_shuffle")
	else:
		# 否则从牌库取出一张牌到废牌堆
		var card_last  = GameSettings.stock_cards.pop()
		emit_signal("stock_card_popped",card_last)
		
	_update_texture()
