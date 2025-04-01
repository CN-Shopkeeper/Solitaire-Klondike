extends Control

@onready var card_texture: TextureRect = $CardTexture
@onready var shadow: TextureRect = $Shadow
@onready var area: Area2D = $Area

@export var card_face: Texture2D = preload("res://asserts/cards/hearts_A.png")
@export var angle_x_max: float = 15.0
@export var angle_y_max: float = 15.0
@export var max_offset_shadow: float = 20.0


var card: ClassCard = ClassCard.new("hearts", "A")

var legal_position: Vector2
var tween_move: Tween



var is_activate: bool:
	get:
		return ((card.is_on_top or card.is_in_order)
			and not _is_moving
			and not card.is_flipped
			and not card.is_completed
		)


var is_following_mouse: bool = false
var following_position: Vector2

var tween_rot: Tween
var tween_hover: Tween
var tween_destroy: Tween

var _is_moving: bool = false:
	set(value):
		if value != _is_moving:
			_is_moving = value
			_on_card_state_changed()

func _ready() -> void:
	area.add_to_group("card_area")
	angle_x_max = deg_to_rad(angle_x_max)
	angle_y_max = deg_to_rad(angle_y_max)

func _process(delta: float) -> void:
	_handle_shadow(delta)

func set_card(_card: ClassCard) -> void:
	card = _card
	card.owning_node = weakref(self)
	card_face = load(card.get_texture_path())
	card.connect("card_state_changed", Callable(self, "_on_card_state_changed"))
	_update_texture()


func tween_position(to_pos: Vector2, duration: float, from_pos: Vector2 = Vector2.ZERO, delay = 0.0):
	stop_hover()
	_stop_rot()
	if tween_move and tween_move.is_running():
		tween_move.kill()

	_is_moving = false
	tween_move = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	_is_moving = true
	tween_move.tween_property(self, "position", to_pos, duration).from(from_pos).set_delay(delay)
	tween_move.finished.connect(func():
		_is_moving = false
	)
	return tween_move


func tween_to_legal_position():
	return tween_position(legal_position, 0.3, position)



# 销毁
func destroy() -> void:
	card_texture.use_parent_material = true
	if tween_destroy and tween_destroy.is_running():
		tween_destroy.kill()

	tween_destroy = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_destroy.tween_property(material, "shader_parameter/dissolve_value", 0.0, 2.0).from(1.0)
	tween_destroy.parallel().tween_property(shadow, "self_modulate:a", 0.0, 1.0)
	await tween_destroy.finished
	queue_free()

func _check_move_legal() -> bool:
	var overlapping_areas = area.get_overlapping_areas()
	if overlapping_areas.size() == 0:
		return false
	var is_legal = false
	for oa in overlapping_areas:
		# tableau中的卡牌
		if oa.is_in_group("card_area"):
			var oa_card = oa.get_parent()
			is_legal = GameRules.check_card_move_tableau_card_legal(card, oa_card.card)
			# 如果合法，直接返回
			if is_legal:
				CardNodeManager.move_card_nodes_to_tableau(self, oa_card)
				return true
		# foundation检测区域
		if oa.is_in_group("foundation_area"):
			var oa_foundation = oa.get_parent()
			is_legal = GameRules.check_card_move_foundation_legal(card, oa_foundation.suit)
			if is_legal:
				CardNodeManager.move_card_node_to_foundation(self, oa_foundation.suit)
				return is_legal
		# tableau检测区域
		if oa.is_in_group("tableau_area"):
			var oa_tableau = oa.get_parent()
			is_legal = GameRules.check_card_move_tableau_bottom_legal(card, oa_tableau.group_index)
			if is_legal:
				CardNodeManager.move_card_nodes_to_tableau_bottom(self, oa_tableau.group_index)
				return is_legal
	return false

# 卡牌状况发生了变化
func _on_card_state_changed():
	_update_texture()
	area.monitorable = is_activate and card.is_on_top


func _update_texture():
	if card.is_flipped:
		card_texture.set_texture(GameSettings.get_card_back())
	else:
		card_texture.set_texture(card_face)
	if card.is_completed:
		shadow.visible = false
	else:
		shadow.visible = true

func _handle_shadow(delta: float) -> void:
	var center: Vector2 = get_viewport_rect().size / 2.0
	var distance: float = global_position.x -center.x

	shadow.position.x = lerp(0.0, max_offset_shadow * sign(distance), abs(distance / center.x))


func _handle_mouse_click(event: InputEvent) -> void:
	if not is_activate: return
	if event.button_index != MOUSE_BUTTON_LEFT: return

	if event.is_pressed():
		is_following_mouse = true

		following_position = get_local_mouse_position()

		# 修改其order下的所有卡牌
		# 创建一个临时的移动group
		CardNodeManager.create_move_group_tmp(self)
		get_tree().call_group("move_group_tmp", "_update_z_index", card.point, 1)
		# 关闭被碰撞检测
		get_tree().call_group("move_group_tmp", "_disable_monitorable")

	else:
		is_following_mouse = false

		# (有条件地)开启被碰撞检测
		get_tree().call_group("move_group_tmp", "_enable_monitorable")

		get_tree().call_group("move_group_tmp", "_reset_z_index")

		if not _check_move_legal():
			get_tree().call_group("move_group_tmp", "tween_to_legal_position")
		CardNodeManager.delete_move_group_tmp()

func _handle_mouse_move(event: InputEvent) -> void:
	if not is_activate: return
	if not is_following_mouse: return
	get_tree().call_group("move_group_tmp", "_move", global_position, following_position, event.relative)

func _update_z_index(root_card_point: String, root_z_index: int):
	var point_offset = Poker.get_point_num_value(root_card_point)-Poker.get_point_num_value(card.point)
	z_index = root_z_index + point_offset
	# 让其作为场景树最上层元素来实现输入控制
	get_parent().move_child(self, -1)

func _reset_z_index():
	z_index = 0

func _disable_monitorable():
	area.monitorable = false

func _enable_monitorable():
	area.monitorable = is_activate and card.is_on_top

func _move(root_position: Vector2, relative_position: Vector2, mouse_velocity: Vector2):
	var pos_offset = global_position -root_position
	global_position = get_global_mouse_position()-relative_position + pos_offset

	# 根据鼠标移动速度添加旋转
	var lerp_val_x: float = remap(-mouse_velocity.y, -size.x / 5, size.x / 5, 0, 1)
	var lerp_val_y: float = remap(mouse_velocity.x, -size.y / 5, size.y / 5, 0, 1)

	var rot_x: float = rad_to_deg(lerp_angle(-angle_x_max, angle_x_max, lerp_val_x))
	var rot_y: float = rad_to_deg(lerp_angle(-angle_y_max, angle_y_max, lerp_val_y))

	card_texture.material.set_shader_parameter("x_rot", rot_x)
	card_texture.material.set_shader_parameter("y_rot", rot_y)
	pass

func hover():
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(self, "scale", Vector2(1.1, 1.1), 0.5)

func _stop_rot():
	if tween_rot and tween_rot.is_running():
		tween_rot.kill()
	tween_rot = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(true)
	tween_rot.tween_property(card_texture.material, "shader_parameter/x_rot", 0.0, 0.5)
	tween_rot.tween_property(card_texture.material, "shader_parameter/y_rot", 0.0, 0.5)

func stop_hover():
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(self, "scale", Vector2.ONE, 0.5)

func _on_gui_input(event: InputEvent) -> void:
	if not is_activate: return
	if event is InputEventMouseButton:
		_handle_mouse_click(event)
	elif event is InputEventMouseMotion:
		_handle_mouse_move(event)


func _on_mouse_exited() -> void:
	if not is_activate: return
	_stop_rot()
	# 其顺序下的所有卡牌都hover
	var nodes = CardNodeManager.find_ordering_card_nodes(self)
	for node in nodes:
		node.stop_hover()


func _on_mouse_entered() -> void:
	if not is_activate: return
	# 其顺序下的所有卡牌都hover
	var nodes = CardNodeManager.find_ordering_card_nodes(self)
	for node in nodes:
		node.hover()
