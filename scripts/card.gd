extends Control

@onready var card_texture: TextureRect = $CardTexture
@onready var shadow: TextureRect = $Shadow
@onready var area: Area2D = $Area

@export var card_face:Texture2D=preload("res://asserts/cards/hearts_A.png")
@export var angle_x_max:float =15.0
@export var angle_y_max:float =15.0
@export var max_offset_shadow:float=20.0


var card:ClassCard=ClassCard.new("hearts","A")

var legal_position:Vector2
var tween_move:Tween

var is_activate:bool:
	get:
		return card.is_on_top and not card.is_flipped and (not tween_move or not tween_move.is_running())

var _previous_is_activate:bool
			
var is_following_mouse:bool=false

var tween_rot:Tween
var tween_hover:Tween
var tween_destroy:Tween

func _ready() -> void:
	area.add_to_group("card_area")
	angle_x_max=deg_to_rad(angle_x_max)
	angle_y_max=deg_to_rad(angle_y_max)

func _process(delta: float) -> void:
	_handle_shadow(delta)
	_follow_mouse(delta)

func set_card(_card:ClassCard)->void:
	card=_card
	card_face=load(card.get_texture_path())
	card.connect("card_state_changed", Callable(self, "_on_card_state_changed"))
	_update_texture()

func tween_position(to_pos:Vector2,duration:float,from_pos:Vector2=Vector2.ZERO,delay=0.0):
	_stop_hover()
	_stop_rot()
	if tween_move and tween_move.is_running():
		tween_move.kill()
	tween_move= create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_move.tween_property(self,"position",to_pos,duration).from(from_pos).set_delay(delay)
	return tween_move

func tween_to_legal_position():
	tween_position(legal_position,0.3,position)

# 销毁
func destroy()->void:
	card_texture.use_parent_material=true
	if tween_destroy and tween_destroy.is_running():
		tween_destroy.kill()
		
	tween_destroy=create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_destroy.tween_property(material,"shader_parameter/dissolve_value",0.0,2.0).from(1.0)
	tween_destroy.parallel().tween_property(shadow,"self_modulate:a",0.0,1.0)
	await tween_destroy.finished
	queue_free()

func _check_move_legal()->bool:
	var overlapping_areas = area.get_overlapping_areas()
	if overlapping_areas.size()==0:
		return false
	for oa in overlapping_areas:
		if oa.is_in_group("card_area"):
			var oa_card=oa.get_parent()
			var is_legal  = GameSettings.check_card_move_legal(card,oa_card.card)
			if is_legal:
				GameSettings.move_card_to_tableau(self,oa_card)
			return is_legal
	return false

func _on_card_state_changed():
	var new_value = is_activate
	if new_value != _previous_is_activate:
		_previous_is_activate = new_value
		_update_texture()
		area.monitorable=is_activate

func _update_texture():	
	if card.is_flipped:
		card_texture.set_texture(GameSettings.get_card_back())
	else:
		card_texture.set_texture(card_face)
	
func _handle_shadow(delta:float)->void:
	var center: Vector2 = get_viewport_rect().size/2.0
	var distance:float = global_position.x-center.x
	
	shadow.position.x = lerp(0.0,max_offset_shadow*sign(distance),abs(distance/center.x))
	
func _follow_mouse(delta:float)->void:
	if not is_activate: return
	if not is_following_mouse: return
	global_position = get_global_mouse_position()-size/2

func _handle_mouse_click(event: InputEvent)->void:
	if not is_activate: return
	if not event is InputEventMouseButton:return
	if event.button_index!=MOUSE_BUTTON_LEFT:return
	
	if event.is_pressed():
		is_following_mouse=true
		z_index=1
		# 让其作为场景树最上层元素来实现输入控制
		get_parent().move_child(self,-1)
	else:
		is_following_mouse=false
		z_index=0
		if not _check_move_legal():
			tween_to_legal_position()

func _stop_rot():
	if tween_rot and tween_rot.is_running():
		tween_rot.kill()
	tween_rot=create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(true)
	tween_rot.tween_property(card_texture.material,"shader_parameter/x_rot",0.0,0.5)
	tween_rot.tween_property(card_texture.material,"shader_parameter/y_rot",0.0,0.5)
	
func _stop_hover():
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
	tween_hover=create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(self,"scale",Vector2.ONE,0.5)

func _on_gui_input(event: InputEvent) -> void:
	if not is_activate: return
	_handle_mouse_click(event)
	if is_following_mouse: return
	if not event is InputEventMouseMotion: return
	var mouse_pos :Vector2 =get_local_mouse_position()
	var lerp_val_x:float = remap(mouse_pos.x,0.0,size.x,0,1)
	var lerp_val_y:float = remap(mouse_pos.y,0.0,size.y,0,1)
	
	var rot_x :float= rad_to_deg(lerp_angle(-angle_x_max,angle_x_max,lerp_val_x))
	var rot_y :float= rad_to_deg(lerp_angle(-angle_y_max,angle_y_max,lerp_val_y)) 
	
	card_texture.material.set_shader_parameter("x_rot",rot_x)
	card_texture.material.set_shader_parameter("y_rot",rot_y)
	

func _on_mouse_exited() -> void:
	if not is_activate: return
	_stop_rot()
	_stop_hover()
	

func _on_mouse_entered() -> void:
	if not is_activate: return
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
	tween_hover=create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(self,"scale",Vector2(1.2,1.2),0.5)
