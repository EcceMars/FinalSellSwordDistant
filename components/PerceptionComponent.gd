## Deals with entity context, such as vision (implementations for sound will come later)
class_name PerceptionComponent
extends BaseComponent

var attention_limit:int = 3
var max_attempts:int = 10
var vision_range:Dictionary = {
	'length': 14.0,
	'width': 6.0,
	'back_ratio': 0.1
	}

var scan_pattern:Pattern = Pattern.RANDOM
var scan_speed:float = 1.0
var forward_ratio:float = 0.7

enum Pattern {
	RANDOM,
	
	JITTERY,
	SWEEPING,		## Slow sweep
	ERRATIC,			## Quick, random angles
	FOCUSED			## Usually forwards
	}

var debug:bool = false

var _angle:float = 0.0
var _sweep_dir:int = 1

func look()->Array[RayResult]:
	var results:Array[RayResult] = []
	var attempt:int = 0
	var found:int = 0

	_update_angle()
	
	while found < attention_limit and attempt < max_attempts:
		var ray_angle:float = _next_angle()
		var result:RayResult = _cast_ray(ray_angle)
		attempt += 1
		
		if result and _is_new_entity(result.hit_entity, results):
			results.append(result)
			found += 1
	if debug: _draw_debug(results)
	for n:int in attention_limit:
		var scenary:RayResult = _scan_scenery(_next_angle())
		if scenary and scenary.raw_data == 'water':
			results += [scenary]
			break
	return results
func _update_angle()->void:
	match scan_pattern:
		Pattern.SWEEPING:
			_angle += DIR.delta * scan_speed * _sweep_dir
			if abs(_angle) > vision_range.width * 0.5:
				_sweep_dir *= -1
		Pattern.ERRATIC:
			if randf() < DIR.delta * scan_speed:
				_angle = randf_range(-vision_range.width, vision_range.width) * 0.5
		Pattern.FOCUSED:
			if randf() < 0.1:
				_angle = randf_range(-vision_range.width, vision_range.width) * 0.5
			else:
				_angle = move_toward(_angle, 0.0, DIR.delta)
func _next_angle()->float:
	var base_angle:float = 0.0
	match scan_pattern:
		Pattern.RANDOM:
			return randf_range(-vision_range.width, vision_range.width) * 0.5
		Pattern.JITTERY:
			base_angle = _angle
			var jitter:float = randf_range(-0.5, 0.5) * (1.0 - forward_ratio)
			return base_angle + jitter
		Pattern.SWEEPING:
			return _angle + randf_range(-0.2, 0.2)
		Pattern.ERRATIC:
			return _angle
		Pattern.FOCUSED:
			if randf() < forward_ratio:
				return 0.0
			else:
				return _angle
	return base_angle
func _cast_ray(angle:float)->RayResult:
	var movement:MovementComponent = get_movement()
	if not movement: return null
	
	var facing:float = 1.0 if movement.faces_right else -1.0
	var ray_dir:Vector2 = Vector2.RIGHT.rotated(angle * facing) * facing
	
	var offset:Vector2 = Vector2(vision_range.back_ratio * DIR.SCALE * facing, 0)
	var ray_start:Vector2 = movement.position + offset
	
	var max_dist:float = vision_range.length * DIR.SCALE
	var step_size:float = float(DIR.SCALE) * 0.5
	
	var current_pos:Vector2 = ray_start
	var dist:float = 0.0
	while dist < max_dist:
		current_pos += ray_dir * step_size
		dist += step_size
		
		var grid_pos:Vector2i = MovementSystem.world_to_grid(current_pos)
		for other:int in DIR.get_entities_at(grid_pos):
			if other < 0 or other == uid:		# Should block entities from perceiving themselves
				continue
			
			return RayResult.new(
				other,
				current_pos,
				dist,
				angle
				)
	return null
## As of now, finds water.
func _scan_scenery(angle:float)->RayResult:
	var movement:MovementComponent = get_movement()
	if not movement: return null
	
	var TERSYS:TerrainSystem = DIR.get_system(TerrainSystem)
	
	var facing:float = 1.0 if movement.faces_right else -1.0
	var ray_dir:Vector2 = Vector2.RIGHT.rotated(angle * facing) * facing
	
	var offset:Vector2 = Vector2(vision_range.back_ratio * DIR.SCALE * facing, 0)
	var ray_start:Vector2 = movement.position + offset
	
	var max_dist:float = vision_range.length * DIR.SCALE
	var step_size:float = float(DIR.SCALE) * 0.5
	
	var current_pos:Vector2 = ray_start
	var dist:float = 0.0
	while dist < max_dist:
		current_pos += ray_dir * step_size
		dist += step_size

		var biome:TerrainSystem.BIOME = TERSYS.get_biome(current_pos)
		if biome == TerrainSystem.BIOME.WATER:
			var result:RayResult = RayResult.new(
				-1,
				# Attempts to find a closer to the entity tile of water (preventing an entity from trying to go to the middle of a body of water)
				TERSYS.nearest_water(ray_start.lerp(current_pos, 0.1)),
				dist,
				angle
				)
			result.raw_data = 'water'
			return result
	return null
func _draw_debug(various:Array[RayResult])->void:
		if various:
			for ray:RayResult in various:
				var movement:MovementComponent = get_movement()
				var start:Vector2 = movement.position
				DIR.DEBUG.draw_arrow(start, ray.hit_point + Vector2.UP * DIR.SCALE)
			return
func _is_new_entity(other:int, current:Array[RayResult])->bool:
	for result:RayResult in current:
		if result.hit_entity == other:
			return false
	return true
class RayResult:
	var hit_entity:int = -1
	var hit_point:Vector2 = DIR.NULL_POS
	var distance:float = 0.0
	var ray_angle:float = 0.0
	var raw_data:String = ''
	
	func _init(who:int, position:Vector2, dist:float, angle:float)->void:
		hit_entity = who
		hit_point = position
		distance = dist
		ray_angle = angle
	func _to_string()->String:
		var message:String = get_script().get_global_name()
		message += "\n\te%d\n\tp%v\n\td[%.2f]\n\ta[%.2f]" % [hit_entity, hit_point, distance, ray_angle]
		return message
