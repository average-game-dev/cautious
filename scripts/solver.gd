extends Node3D

@onready var player: Node = get_node("../player")
@onready var camera: Camera3D = player.get_node("Camera3D")

# State for solver object manipulation
var solver_s_state := solver_s_state_enum.off
var solver_selected_object: RigidBody3D = null
var solver_distance: float = 10.0

enum solver_s_state_enum {
	off,
	transforming,
	rotating,
	scaling
	#editing
	
}

# for transform solving
var transform_x_offset: float = 0.0
var transform_y_offset: float = 0.0
var transform_z_offset: float = 0.0

# for rotation solving 
var rotate_y_offset: float = 0.0
var rotate_x_offset: float = 0.0
var rotate_z_offset: float = 0.0

# for scale solving
var scale_x_offset: float = 1.0
var scale_y_offset: float = 1.0
var scale_z_offset: float = 1.0

const solver_s_state_num: int = len(solver_s_state_enum) - 1

var textures := {}
var solver_state: bool = false

func _ready() -> void:
	var solver_base := player.get_node("CanvasLayer/Control/main_hud/solver-indicator")

	textures = {
		"off": solver_base.get_node("off"),
		"main": solver_base.get_node("main"),
		"scale": solver_base.get_node("scale"),
		"rotate": solver_base.get_node("rotate"),
	}

	player.connect("solver_toggle", _solver_toggle)
	player.connect("solver_target_set", _solver_target_set)
	player.connect("solver_target_drop", _solver_target_drop)
	player.connect("solver_hold_dist_up", _solver_hold_dist_up)	
	player.connect("solver_hold_dist_down", _solver_hold_dist_down)	
	player.connect("solver_cycle", _solver_cycle)
	player.connect("solver_forward", _solver_forward)
	player.connect("solver_backward", _solver_backward)
	player.connect("solver_alt_forward", _solver_alt_forward)
	player.connect("solver_alt_backward", _solver_alt_backward)
	player.connect("solver_left", _solver_left)
	player.connect("solver_right", _solver_right)
	player.connect("solver_alt_left", _solver_alt_left)
	player.connect("solver_alt_right", _solver_alt_right)
	player.connect("solver_offset_reset", _solver_offset_reset)
	
func show_state(name: String) -> void:
	for tex_name in textures:
		textures[tex_name].visible = (tex_name == name)

# helpers
func get_enum_key_by_value(enum_dict: Dictionary, value) -> String:
	for key in enum_dict.keys():
		if enum_dict[key] == value:
			return str(key)
	return ""  # Not found

# dumb satanic bullshit never to be touched for a million years
func set_rotation_of_rb3d(target: RigidBody3D, roto: Vector3) -> void:
	var original_freeze_mode = target.freeze_mode
	target.freeze_mode = RigidBody3D.FreezeMode.FREEZE_MODE_STATIC
	target.rotation_degrees = roto
	target.freeze_mode = original_freeze_mode
	
func set_scale_of_rb3d(target: RigidBody3D, scalee: Vector3):
	var mesh = target.get_child(0)
	var coll = target.get_child(1)
	
	mesh.scale = scalee
	coll.scale = scalee

func _solver_forward():
	if solver_s_state == solver_s_state_enum.transforming:
		if transform_y_offset < 20:
			transform_y_offset += 0.2
	elif solver_s_state == solver_s_state_enum.rotating:
			rotate_z_offset -= 2
	elif solver_s_state == solver_s_state_enum.scaling:
		if scale_y_offset < 3.0:
			scale_y_offset += 0.05
			
func _solver_backward():
	if solver_s_state == solver_s_state_enum.transforming:
		if transform_y_offset > -20:
			transform_y_offset -= 0.2
	elif solver_s_state == solver_s_state_enum.rotating:
		rotate_z_offset += 2
	elif solver_s_state == solver_s_state_enum.scaling:
		if scale_y_offset > 0.1:
			scale_y_offset -= 0.05

func _solver_left():
	if solver_s_state == solver_s_state_enum.transforming:
		if transform_x_offset > -20:
			transform_x_offset -= 0.2
	elif solver_s_state == solver_s_state_enum.rotating:
		rotate_y_offset += 2
	elif solver_s_state == solver_s_state_enum.scaling:
		if scale_x_offset < 3.0:
			scale_x_offset += 0.05

func _solver_right():
	if solver_s_state == solver_s_state_enum.transforming:
		if transform_x_offset < 20:
			transform_x_offset += 0.2
	elif solver_s_state == solver_s_state_enum.rotating:
		rotate_y_offset -= 2
	elif solver_s_state == solver_s_state_enum.scaling:
		if scale_x_offset > 0.1:
			scale_x_offset -= 0.05
			
func _solver_alt_forward():
	if solver_s_state == solver_s_state_enum.transforming:
		pass
	elif solver_s_state == solver_s_state_enum.rotating:
		pass
	elif solver_s_state == solver_s_state_enum.scaling:
		if scale_x_offset < 3.0:
			scale_x_offset += 0.05
		if scale_y_offset < 3.0:
			scale_y_offset += 0.05
		if scale_z_offset < 3.0:
			scale_z_offset += 0.05
			
func _solver_alt_backward():
	if solver_s_state == solver_s_state_enum.transforming:
		pass
	elif solver_s_state == solver_s_state_enum.rotating:
		pass
	elif solver_s_state == solver_s_state_enum.scaling:
		if scale_x_offset > 0.1:
			scale_x_offset -= 0.05
		if scale_y_offset > 0.1:
			scale_y_offset -= 0.05
		if scale_z_offset > 0.1:
			scale_z_offset -= 0.05
		
func _solver_alt_left():
	if solver_s_state == solver_s_state_enum.transforming:
		if transform_z_offset < 20.0:
			transform_z_offset += 0.2
	elif solver_s_state == solver_s_state_enum.rotating:
		rotate_x_offset += 2
	elif solver_s_state == solver_s_state_enum.scaling:
		if scale_z_offset < 3.0:
			scale_z_offset += 0.05

func _solver_alt_right():
	if solver_s_state == solver_s_state_enum.transforming:
		if transform_z_offset > -20.0:
			transform_z_offset -= 0.2
	elif solver_s_state == solver_s_state_enum.rotating:
		rotate_x_offset -= 2
	elif solver_s_state == solver_s_state_enum.scaling:
		if scale_z_offset > 0.1:
			scale_z_offset -= 0.05
			
func _solver_offset_reset():
	if solver_s_state == solver_s_state_enum.transforming:
		transform_x_offset = 0.0
		transform_y_offset = 0.0
		transform_z_offset = 0.0
	elif solver_s_state == solver_s_state_enum.rotating:
		rotate_x_offset = 0.0
		rotate_y_offset = 0.0
		rotate_z_offset = 0.0
	elif solver_s_state == solver_s_state_enum.scaling:
		scale_x_offset = 1.0
		scale_y_offset = 1.0
		scale_z_offset = 1.0

func _solver_cycle():
		# If current state number is equal to the max enum value
		if solver_s_state == solver_s_state_num:
			# Reset to 0s
			solver_s_state = 0
		else:
			# Else increment state
			solver_s_state += 1
func _solver_toggle() -> void:
	solver_state = !solver_state
	if not solver_state:
		if solver_selected_object:
			solver_selected_object.gravity_scale = 1.0
		_solver_target_drop()

func _solver_hold_dist_up(by):
	if solver_distance < 20.0:
		solver_distance += by
		
func _solver_hold_dist_down(by):
	if solver_distance > 2.5:
		solver_distance -= by

func _solver_target_set(target: RigidBody3D) -> void:
	if target and target.is_in_group("solver"):
		solver_selected_object = target
		solver_s_state = solver_s_state_enum.transforming
	else:
		if solver_selected_object:
			solver_selected_object.gravity_scale = 1.0
		solver_selected_object = null
		solver_s_state = solver_s_state_enum.off


func _solver_target_drop() -> void:
	if solver_selected_object:
		solver_selected_object.gravity_scale = 1.0
	solver_selected_object = null
	solver_s_state = solver_s_state_enum.off

func apply_solver_velocity(
	target: RigidBody3D,
	camera: Camera3D,
	distance: float,
	_delta: float
) -> void:
	if not target or not camera:
		return
	
	var mass: float = max(target.mass, 1.0) # Avoid division by zero
	var target_pos := camera.global_transform.origin + -camera.global_transform.basis.z * distance
	target_pos = target_pos + Vector3(transform_x_offset, transform_y_offset, transform_z_offset)
	var current_pos := target.global_transform.origin
	var direction := target_pos - current_pos
	
	var dampened_velocity: Vector3 = direction * (10.0 / mass)
	target.linear_velocity = dampened_velocity

func _physics_process(delta: float) -> void:
	if solver_state:
		show_state("main")
		player.set_heat(player.get_heat() + 0.105)
	else:
		show_state("off")
	
	match solver_s_state:
		solver_s_state_enum.transforming:
			if solver_selected_object:
				solver_selected_object.gravity_scale = 0.0
				apply_solver_velocity(solver_selected_object, camera, solver_distance, delta)
				player.set_heat(player.get_heat() + 0.1)
		solver_s_state_enum.rotating:
			if solver_selected_object:
				set_rotation_of_rb3d(solver_selected_object, Vector3(rotate_x_offset, rotate_y_offset, rotate_z_offset))
				show_state("rotate")
				player.set_heat(player.get_heat() + 0.05)
		solver_s_state_enum.scaling:
			if solver_selected_object:
				set_scale_of_rb3d(solver_selected_object, Vector3(scale_x_offset, scale_y_offset, scale_z_offset))
				show_state("scale")
				player.set_heat(player.get_heat() + 0.05)
		solver_s_state_enum.off:
			if solver_selected_object:
				solver_selected_object.gravity_scale = 1.0
