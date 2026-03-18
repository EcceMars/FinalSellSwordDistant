## World class (WARNING: attempt to centralize all calls through here)
class_name Director
extends Node

const DIRECTIONS:Dictionary[String, Vector2i] = {
	'UP':			-Vector2i.UP,
	'UP_LEFT':		-Vector2i.ONE,
	'LEFT':			Vector2i.LEFT,
	'DOWN_LEFT':		Vector2i(-1, 1),
	'DOWN':			Vector2i.DOWN,
	'DOWN_RIGHT':	Vector2i.ONE,
	'RIGHT':			Vector2i.RIGHT,
	'UP_RIGHT':		Vector2i(1, -1)
	}
const NULL_POS:Vector2 = -Vector2.INF
const NULL_GRID:Vector2i = -Vector2i.MAX
const NULL_AREA:Rect2 = Rect2(-Vector2.INF, -Vector2.INF)

var WIDTH:int = 64*5
var HEIGHT:int = 32*5
var GRID_BOUNDS:Vector2i = Vector2i(WIDTH, HEIGHT)

var SCALE:int = 16
var SCALED_POINT:Vector2 = Vector2.ONE * SCALE
var SCALED_BOUNDS:Vector2 = Vector2(GRID_BOUNDS) * SCALE

var MAX_ENTITIES:int = 256*2

## Entity unique id to component bitmask signature
var _entities:Dictionary[int, int] = { -1: 0 }
var _generations:Dictionary[int, int] = { -1: -1 }
var _open_uid:int = 0
var _component_cache:Dictionary[GDScript, Dictionary] = { null: { -1: null} }

## Ticked delta
var delta:float = 0.0

var _map:Dictionary[Vector2i, Array] = {	DIR.NULL_GRID: [-1]		}
var _systems:Dictionary[GDScript, BaseSystem] = {}

var CAM_MANAGER:CAMERA_MANAGER = null
var DEBUG:DebugLayer = null
var SPRITES:Node2D = null
var TERRAIN_LAYER:Node2D = null

var ENTITYSTORE:EntityStore = null

func start(MAIN:Node, max_entities:int = MAX_ENTITIES, width:int = WIDTH, height:int = HEIGHT, scale:int = SCALE, _seed:int = 0)->void:
	MAX_ENTITIES = max_entities
	for i:int in MAX_ENTITIES:
		_entities[i] = 0
	
	WIDTH = width
	HEIGHT = height
	GRID_BOUNDS = Vector2i(WIDTH -1, HEIGHT -1)
	
	SCALE = scale
	SCALED_POINT = Vector2.ONE * SCALE
	SCALED_BOUNDS = Vector2(GRID_BOUNDS) * SCALE
	
	for row:int in range(0, HEIGHT):
		for col:int in range(0, WIDTH):
			var point:Vector2i = Vector2i(col, row)
			_map[point] = [-1]
	
	CAM_MANAGER = MAIN.cam_manager
	
	DEBUG = DebugLayer.new()
	DEBUG.name = "DebugLayer"
	DEBUG.config()
	DEBUG.y_sort_enabled = true
	
	SPRITES = Node2D.new()
	SPRITES.name = "Sprites"
	SPRITES.y_sort_enabled = true
	
	TERRAIN_LAYER = Node2D.new()
	TERRAIN_LAYER.name = "Terrain"
	TERRAIN_LAYER.z_index = -10
	
	MAIN.add_child(DEBUG)
	MAIN.add_child(SPRITES)
	MAIN.add_child(TERRAIN_LAYER)
	
	ENTITYSTORE = MAIN.archetypes
	
	for component_type:GDScript in BaseComponent._REGISTERED:
		_component_cache[component_type] = {}
func system_start(system_class:GDScript, ...sys_params:Array)->BaseSystem:
	if not BaseSystem._REGISTRY.has(system_class): return null
	_systems[system_class] = system_class.new(sys_params)
	return _systems[system_class]
func get_system(system_class:GDScript)->BaseSystem:
	return _systems[system_class]
func register_entity(uid:int)->void:
	_entities[uid] = 0
## Destroys an entity and removes all its components.
## Uses swap-and-pop pattern for O(1) removal.
func destroy_entity(uid:int)->void:
	if not is_valid_entity(uid): return

	var last_uid:int = _open_uid - 1
	for type:GDScript in _component_cache:
		if not _component_cache[type]: continue
		
		var component:BaseComponent = _component_cache[type].get(uid)
		if component: component.destroy()
		_component_cache[type].erase(uid)
	if uid != last_uid:
		_entities[uid] = _entities[last_uid]
		for type:GDScript in _component_cache:
			if not _component_cache[type]: continue
			var component: BaseComponent = _component_cache[type].get(last_uid)
			if component:
				component.uid = uid
				_component_cache[type][uid] = component
			_component_cache[type].erase(last_uid)
	_entities[last_uid] = 0
	_open_uid -= 1
	_generations[uid] = _generations.get(uid, 0) + 1
func get_entity_mask(uid:int)->int:
	return _entities.get(uid)
## Register [param component] to uid.
func add_component(uid:int, component:BaseComponent, override:bool = false)->BaseComponent:
	if not is_valid_entity(uid): return null
	if not component or not component.flag: return null
	
	_entities[uid] |= component.flag
	var type_class:GDScript = component.get_script()
	if not override and _component_cache[type_class].get(uid): return _component_cache[type_class][uid]
	_component_cache[type_class][uid] = component
	return _component_cache[type_class][uid]
## Undoes the entity|component register and deletes the component
func delete_component(uid:int, comp_class:GDScript)->void:
	var component:BaseComponent = get_component(uid, comp_class)
	if not component:
		return
	component.destroy()
	if not _component_cache[comp_class].get(uid): return
	
	var as_flag:BaseComponent.CFLAG = component.flag
	_entities[uid] &= ~as_flag
	_component_cache[comp_class].erase(uid)
func get_component(uid:int, component_type:GDScript)->BaseComponent:
	return _component_cache[component_type].get(uid)
func get_all_components(uid:int)->Array[BaseComponent]:
	if not is_valid_entity(uid): return []
	var result:Array[BaseComponent] = []
	for comp_type:GDScript in BaseComponent._REGISTERED:
		if _component_cache[comp_type].has(uid):
			result.append(_component_cache[comp_type][uid])
	return result
func request_all_components_of(component_type:GDScript)->Array:
	return _component_cache[component_type].values()
## Query all entities using a bitmask
func get_entities_by(bitmask:int)->Array[int]:
	var result:Array[int] = []
	for uid:int in _open_uid:
		if has_components(uid, bitmask):
			result.append(uid)
	return result
func has_components(uid:int, required_mask:int)->bool:
	if not is_valid_entity(uid):
		return false
	return (_entities[uid] & required_mask) == required_mask
func query_entities_by_texture_and_position(point:Vector2, radius:int = 3)->int:
	var candidates:Array = get_entities_near(MovementSystem.world_to_grid(point), radius)
	print("CLICKED AT ", MovementSystem.world_to_grid(point), " | _map returns ", DIR.get_entities_near(MovementSystem.world_to_grid(point)))
	for uid:int in candidates:
		var visual:VisualComponent = get_component(uid, VisualComponent)
		if visual and visual.contains_point(point):
			return uid
	return -1
func update_ent_position(uid:int, old_position:Vector2, new_position:Vector2)->void:
	var old_posi:Vector2i = MovementSystem.world_to_grid(old_position)
	var new_posi:Vector2i = MovementSystem.world_to_grid(new_position)
	if _map.get(old_posi): _map[old_posi].erase(uid)
	if not _map.get(new_posi): _map[new_posi] = []
	_map[new_posi].append(uid)
func get_ent_position(uid:int, pos_fallback:Vector2 = Vector2.ZERO)->Vector2:
	var movement:MovementComponent = get_component(uid, MovementComponent)
	if movement:
		return movement.position
	return pos_fallback
func get_entities_at(grid_point:Vector2i)->Array:
	if not _map.get(grid_point): return []
	return _map.get(grid_point)
func get_entities_near(grid_point:Vector2i, radius:int = 1)->Array:
	var entities:Array = []
	for dy:int in range(-radius, radius + 1):
		for dx:int in range(-radius, radius + 1):
			var cell:Vector2i = grid_point + Vector2i(dx, dy)
			var at_cell:Array = _map.get(cell, [])
			for id:int in at_cell:
				if id >= 0 and not entities.has(id): entities.append(id)
	return entities
func rand_restricted(movement:MovementComponent)->Vector2:
	var new_point:Vector2 = DIR.NULL_POS
	var TERSYS:TerrainSystem = get_system(TerrainSystem)
	while new_point == DIR.NULL_POS or not movement.natural_biome(TERSYS.get_biome(new_point)):
		new_point = rand_point()
	return new_point
func rand_point() -> Vector2:
	var grid:Vector2i = Vector2i(randi() % WIDTH, randi() % HEIGHT)
	return MovementSystem.grid_to_world(grid)

func _request_uid()->int:
	if _open_uid >= DIR.MAX_ENTITIES: return -1
	var uid:int = _open_uid
	_open_uid += 1
	_generations[uid] = _generations.get(uid, 0)
	return uid
func is_valid_entity(uid:int)->bool:
	return uid in range(0, _open_uid) and _entities.has(uid)
