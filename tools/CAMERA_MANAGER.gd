## Manages camera movement, panning, edge scrolling, and cinematic functions.
@icon("editor/icons/Camera2D.svg")
class_name CAMERA_MANAGER
extends Node2D

## Reference to the Camera2D node
@export var camera:Camera2D = null
## Current target position for smooth movement
var target_position:Vector2 = Vector2.ZERO

const CLICK_AREA:float = 1.2
## Camera movement speed
const BASE_SPEED:float = 4.0
## Acceleration for smooth movement
var acceleration:float = 0.0
## Edge scroll settings
const EDGE_SCROLL_MARGIN:float = 32.0
const EDGE_SCROLL_SPEED:float = 200.0
@export var permit_edge_scrool:bool = false

## Pan settings
@export var is_panning:bool = false
var pan_start_pos:Vector2 = Vector2.ZERO
var pan_start_cam_pos:Vector2 = Vector2.ZERO

## Follow settings
@export var follow_uid:int = -1
@export var follow_enabled:bool = false

## World bounds
var world_min:Vector2 = Vector2.ZERO
var world_max:Vector2 = Vector2.ZERO

## Zoom limits
const MIN_ZOOM:float = 0.1
@export var MAX_ZOOM:float = 3.0
const ZOOM_STEP:float = 0.1

func start(target:Vector2 = target_position)->void:
	world_max = Vector2(DIR.WIDTH, DIR.HEIGHT) * DIR.SCALE
	target_position = Vector2(DIR.WIDTH * 0.5, DIR.HEIGHT * 0.5) * DIR.SCALE
	target_position = target
	position = target_position

## Main update function - call from _process
func process(delta:float)->void:
	_handle_zoom_input()
	_handle_pan_input()
	_handle_edge_scroll(delta)
	_handle_follow()
	_handle_quick_follow()
	_smooth_add_velocity_target()

## Handle mouse wheel zoom
func _handle_zoom_input()->void:
	if Input.is_action_just_released("wheel_down"):
		camera.zoom = (camera.zoom - Vector2.ONE * ZOOM_STEP).clamp(
			Vector2.ONE * MIN_ZOOM, 
			Vector2.ONE * MAX_ZOOM
		)
	
	if Input.is_action_just_released("wheel_up"):
		camera.zoom = (camera.zoom + Vector2.ONE * ZOOM_STEP).clamp(
			Vector2.ONE * MIN_ZOOM, 
			Vector2.ONE * MAX_ZOOM
		)

## Handle middle mouse button panning
func _handle_pan_input()->void:
	if Input.is_action_just_pressed("pan_camera"):
		is_panning = true
		pan_start_pos = camera.get_viewport().get_mouse_position()
		pan_start_cam_pos = position
		follow_enabled = false
	
	if Input.is_action_just_released("pan_camera"):
		is_panning = false
	
	if is_panning:
		var current_mouse:Vector2 = camera.get_viewport().get_mouse_position()
		var delta_mouse:Vector2 = pan_start_pos - current_mouse
		target_position = _clamp_position(pan_start_cam_pos + delta_mouse / camera.zoom.x)

## Handle edge scrolling when mouse is near viewport edges
func _handle_edge_scroll(delta:float)->void:
	if not permit_edge_scrool: return
	if is_panning or follow_enabled:
		return
	
	var viewport:Viewport = camera.get_viewport()
	var mouse_pos:Vector2 = viewport.get_mouse_position()
	var viewport_size:Vector2 = viewport.get_visible_rect().size
	
	var scroll_dir:Vector2 = Vector2.ZERO
	
	if mouse_pos.x < EDGE_SCROLL_MARGIN:
		scroll_dir.x = -1.0
	elif mouse_pos.x > viewport_size.x - EDGE_SCROLL_MARGIN:
		scroll_dir.x = 1.0
	
	if mouse_pos.y < EDGE_SCROLL_MARGIN:
		scroll_dir.y = -1.0
	elif mouse_pos.y > viewport_size.y - EDGE_SCROLL_MARGIN:
		scroll_dir.y = 1.0
	
	if scroll_dir != Vector2.ZERO:
		target_position = _clamp_position(
			target_position + scroll_dir.normalized() * EDGE_SCROLL_SPEED * delta
		)
## Handle following an entity
func _handle_follow()->void:
	if not follow_enabled or follow_uid == -1:
		return
	
	var pos:Vector2 = DIR.get_ent_position(follow_uid, position)
	if pos != Vector2.ZERO:
		target_position = _clamp_position(pos)
## Centers the camera on the setted [member follow_uid] when 'space' is pressed.
func _handle_quick_follow()->void:
	if follow_uid < 0: return
	
	if Input.is_action_just_released("follow_entity"):
		var pos:Vector2 = DIR.get_ent_position(follow_uid, position)
		if pos != Vector2.ZERO:
			target_position = _clamp_position(pos)
## Smooth movement to target position
func _smooth_add_velocity_target()->void:
	if position.distance_to(target_position) < 2.0:
		position = target_position
		acceleration = 0.0
		
		return
	
	position = position.move_toward(
		target_position, 
		BASE_SPEED + acceleration
	)
	acceleration = clampf(acceleration + 1.0, 0.0, BASE_SPEED * 2.0)

## Clamp camera position to world bounds
func _clamp_position(pos:Vector2)->Vector2:
	return pos.clamp(world_min, world_max)

## Cinematic: Move camera to a specific position
func add_velocity(pos:Vector2)->void:
	follow_enabled = false
	target_position = _clamp_position(pos)
	acceleration = 0.0

## Cinematic: Follow an entity by UID
func follow_entity(uid:int)->void:
	if not DIR.ER.is_valid_entity(uid):
		push_warning("[CameraManager] Cannot follow invalid entity: %d" % uid)
		return
	
	follow_uid = uid
	follow_enabled = true

## Stop following current entity
func stop_follow()->void:
	follow_enabled = false
	follow_uid = -1

## Cinematic: Camera shake effect
func shake(intensity:float = 5.0, duration:float = 0.3)->void:
	if not is_instance_valid(camera):
		return
	
	#var original_pos:Vector2 = position
	var shake_tween:Tween = camera.create_tween()
	
	var shake_count:int = int(duration * 60.0)
	for i:int in shake_count:
		var offset:Vector2 = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		shake_tween.tween_property(
			camera, 
			"offset", 
			offset, 
			duration / shake_count
		)
	
	shake_tween.tween_property(camera, "offset", Vector2.ZERO, 0.1)

## Set world boundaries for camera clamping
func set_world_bounds(min_pos:Vector2, max_pos:Vector2)->void:
	world_min = min_pos
	world_max = max_pos
