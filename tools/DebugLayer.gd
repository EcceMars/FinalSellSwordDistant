class_name DebugLayer
extends Node2D

var SCALE:float = 0.0
var BOUNDS:Vector2 = Vector2.ZERO
var TILE:ReferenceRect = null

var INFO_UI_PANEL:EntityInfoPanel = null
var CANVAS:CanvasLayer = null

var _permanent:Array = []				## Array of nodes to keep drawing (should be used only for small debugging sets)
var _timed:Dictionary[Array, float] = {}			## Fading debug
var show_hitboxes:bool = true

var _hitbox_layer:HitboxDrawer = null

func watch_hitbox(uid:int)->void:
	if not _hitbox_layer.uids.has(uid):
		_hitbox_layer.uids.append(uid)

func unwatch_hitbox(uid:int)->void:
	_hitbox_layer.uids.erase(uid)

func process()->void:
	INFO_UI_PANEL.update()
	_hitbox_layer.queue_redraw()
	if Input.is_action_just_released("left_click"):
		var world_point:Vector2 = DIR.SPRITES.get_global_mouse_position()
		var clicked_uid:int = DIR.query_entities_by_texture_and_position(world_point)
		INFO_UI_PANEL.show_entity(clicked_uid)
	for group:Array in _timed.keys():
		if _timed[group] < 0.0:
			for node:Node in group:
				node.queue_free()
			_timed.erase(group)
			continue
		_timed[group] -= DIR.delta
## Should be called at [Director]
func config()->void:
	SCALE = DIR.SCALE
	BOUNDS = Vector2(DIR.SCALED_BOUNDS)
	TILE = ReferenceRect.new()
	TILE.editor_only = false
	TILE.size = DIR.SCALED_POINT
	TILE.border_color = Color.RED
	
	_hitbox_layer = HitboxDrawer.new()
	_hitbox_layer.top_level = true
	_hitbox_layer.z_index += 1
	_hitbox_layer.name = "HitboxLayer"
	
	CANVAS = CanvasLayer.new()
	add_child(CANVAS)
	add_child(_hitbox_layer)
	
	INFO_UI_PANEL = EntityInfoPanel.new()
	CANVAS.add_child(INFO_UI_PANEL)

## Parameters:
## [param points] tile positions to draw.
## [param color] in which [Color] to draw.
## [param time] if time is set to negative, the debugging tiles will be placed in the [member _permanent] array and not be freed (CAUTION).
## [param local_to] draws an tile at an offseted position.
## [param _name] makes easier to debbug who is calling this drawing.
func draw_tiles(points:Array[Vector2i], color:Color = Color.RED, time:float = 3.0, local_to:Vector2i = Vector2i.ZERO, _name:String = "")->void:
	var group:Array[ReferenceRect] = []
	for point:Vector2i in points:
		var tile:ReferenceRect = TILE.duplicate()
		tile.position = point + local_to
		tile.border_color = color
		if color != Color.RED:
			tile.name = _name + str(get_child_count())
		add_child(tile)
		group.append(tile)
	if time >= 0.0:
		_timed[group] = time
		return
	_permanent += group
## Parameters:
## [param triangle] [Triangle2D] to draw.
## [param movement] serves to set the debug draw to a certain [MovementComponent].
## For any other parameter, see [method draw_tiles].
func draw_a_polygon(triangle:Triangle2D, color:Color = Color(1, 0, 0, 0.2), time:float = 3.0, visual:VisualComponent = null)->void:
	var anchor:Node2D = self
	var poly:Polygon2D = Polygon2D.new()
	poly.name = ""
	if visual:
		poly.name += str(visual.sprite.get_ref().get_resource_path())
		anchor = visual.sprite.get_ref()
	poly.name += str(get_child_count())
	poly.color = color
	poly.polygon = PackedVector2Array([triangle.a, triangle.b, triangle.c])
	anchor.add_child(poly)
	if time >= 0.0:
		_timed[[poly]] = time
		return
	_permanent += [poly]
## Parameters:
## [param start_position] initial position of the arrow.
## [param end_position] final position of the arrow.
func draw_arrow(start_position:Vector2, end_position:Vector2, color:Color = Color(1, 0, 0, 0.2), time:float = 3.0)->void:
	# Calculate direction and length
	var direction:Vector2 = (end_position - start_position).normalized()
	var length:float = start_position.distance_to(end_position)
	
	# Arrow parameters
	var arrow_head_length:float = min(length * 0.3, 20.0)  # 30% of length or max 20 pixels
	var arrow_head_width:float = arrow_head_length * 0.6   # 60% of head length
	var line_width:float = 4.0  # Width of the arrow line
	
	# Calculate perpendicular vector for line width
	var perp:Vector2 = Vector2(-direction.y, direction.x)
	
	# The line should stop before the arrow head
	var line_end:Vector2 = end_position - direction * arrow_head_length
	
	# Create the arrow line as a polygon (a thick line)
	var line_polygon:Polygon2D = Polygon2D.new()
	line_polygon.color = color
	
	# Create a rectangle polygon for the line
	var line_points:PackedVector2Array = [
		start_position + perp * (line_width / 2),
		start_position - perp * (line_width / 2),
		line_end - perp * (line_width / 2),
		line_end + perp * (line_width / 2)
	]
	line_polygon.polygon = line_points
	
	# Create the arrow head polygon
	var head_polygon:Polygon2D = Polygon2D.new()
	head_polygon.color = color
	
	# Arrow head points (triangle)
	var head_points:PackedVector2Array = [
		end_position,  # Tip of the arrow
		end_position - direction * arrow_head_length + perp * (arrow_head_width / 2),
		end_position - direction * arrow_head_length - perp * (arrow_head_width / 2)
	]
	head_polygon.polygon = head_points
	
	# Add both polygons to the scene
	add_child(line_polygon)
	add_child(head_polygon)
	
	line_polygon.position += Vector2(8, 16)
	head_polygon.position += Vector2(8, 16)
	
	# Handle timing/permanent storage
	var group:Array[Polygon2D] = [line_polygon, head_polygon]
	
	if time >= 0.0:
		_timed[group] = time
	else:
		_permanent += group
class HitboxDrawer extends Node2D:
	var uids: Array[int] = []
	func _draw() -> void:
		for uid: int in uids:
			var MOVSYS:MovementSystem = DIR.get_system(MovementSystem)
			var mov:MovementComponent = DIR.get_component(uid, MovementComponent)
			if not mov or not MOVSYS: continue
			var rect: Rect2 = MOVSYS._get_world_rect_at(mov)
			draw_rect(rect, Color(1.0, 0.2, 0.2, 0.8), false, 1.5)
