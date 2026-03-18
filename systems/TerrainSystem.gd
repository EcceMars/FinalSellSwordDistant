class_name TerrainSystem
extends BaseSystem

enum BIOME {
	WATER,
	# SAND,
	GRASS,
	# FOREST,
	# DIRT
	}
var BIOME_COLORS:Dictionary = {
	BIOME.WATER: Color(0.18, 0.42, 0.72),
	# BIOME.SAND: Color(0.85, 0.78, 0.52),
	BIOME.GRASS: Color(0.44, 0.70, 0.30),
	# BIOME.FOREST: Color(0.20, 0.45, 0.18),
	# BIOME.DIRT: Color(0.55, 0.38, 0.22)
	}
var BIOME_THRESHOLDS:Array[Array] = [
	[-0.3, BIOME.WATER],
	# [-0.1, BIOME.SAND],
	[0.4, BIOME.GRASS],
	# [0.7, BIOME.FOREST],
	# [1.0, BIOME.DIRT]
	]

var _biome_map:Dictionary[Vector2i, BIOME] = {}
var _biome_positions:Dictionary[BIOME, Array] = {}

var _noise:FastNoiseLite = null

var WIND_TIME:float = 4.0
var wind_frame:float = 0.3

func start(_seed:int = 0)->void:
	_noise = FastNoiseLite.new()
	_noise.seed = _seed
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_noise.frequency = 0.03
	_generate()
func process()->void:
	wind_frame += DIR.delta
	if wind_frame >= WIND_TIME:
		wind_frame = 0.0
		for uid:int in DIR.get_entities_by(BaseComponent.CFLAG.HEALTH):
			var health:HealthComponent = DIR.get_component(uid, HealthComponent)
			if health.specie == HealthComponent.Species.TREE:
				DIR.get_system(AnimationSystem).change_animation(uid, 'wind', randf())
func _generate()->void:
	for biome:BIOME in BIOME.values():
		_biome_positions[biome] = []
	
	var img:Image = Image.create(DIR.WIDTH, DIR.HEIGHT, false, Image.FORMAT_RGB8)
	for y:int in DIR.HEIGHT:
		for x:int in DIR.WIDTH:
			var pixel:Vector2i = Vector2i(x, y)
			var value:float = _noise.get_noise_2dv(pixel)
			var biome:BIOME = sample_biome(value)
			_biome_map[pixel] = biome
			_biome_positions[biome].append(pixel)
			img.set_pixel(x, y, BIOME_COLORS[biome])
	var texture:ImageTexture = ImageTexture.create_from_image(img)
	var sprite:Sprite2D = Sprite2D.new()
	sprite.name = "MapTexture"
	sprite.texture = texture
	sprite.centered = false
	sprite.scale = Vector2.ONE * DIR.SCALE
	
	DIR.TERRAIN_LAYER.add_child(sprite)
## Returns the [enum Biome] at [param world_pos].
func get_biome(world_pos:Vector2)->BIOME:
	var grid:Vector2i = MovementSystem.world_to_grid(world_pos)
	return _biome_map.get(grid, BIOME.GRASS)
## Returns true if [param world_pos] is a water tile.
func is_water(world_pos:Vector2)->bool:
	return get_biome(world_pos) == BIOME.WATER
## Returns true if any of the 8 neighbours of [param world_pos] is a water tile.
func is_water_adjacent(world_pos: Vector2) -> bool:
	var grid: Vector2i = MovementSystem.world_to_grid(world_pos)
	for dx: int in [-1, 0, 1]:
		for dy: int in [-1, 0, 1]:
			if dx == 0 and dy == 0: continue
			if _biome_map.get(grid + Vector2i(dx, dy)) == BIOME.WATER:
				return true
	return false
## Returns the nearest world position of [param biome] to [param world_pos].
## Returns -Vector2.ONE (out of bounds) if none exists.
func nearest_of_biome(world_pos:Vector2, biome:BIOME)->Vector2:
	var positions:Array = _biome_positions.get(biome, [])
	if positions.is_empty(): return DIR.NULL_POS

	var best_dist:float = INF
	var best_pos:Vector2 = DIR.NULL_POS

	for grid:Vector2i in positions:
		var candidate:Vector2 = Vector2(grid) * DIR.SCALE
		var dist:float = world_pos.distance_to(candidate)
		if dist < best_dist:
			best_dist = dist
			best_pos = candidate

	return best_pos
## Easy get of the closest water tile from a center point.
func nearest_water(world_pos:Vector2)->Vector2:
	return nearest_of_biome(world_pos, BIOME.WATER)
# Optional helper: Sample BIOME from noise value (can be called from registries)
func sample_biome(value:float)->BIOME:
	for threshold: Array in BIOME_THRESHOLDS:
		if value <= threshold[0]:
			return threshold[1]
	return BIOME.GRASS
