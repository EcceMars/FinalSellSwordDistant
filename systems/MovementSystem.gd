## Reads velocity and push from [MovementComponent], resolves terrain and entity
## collision, then commits final positions each frame.
class_name MovementSystem
extends BaseSystem

const NULL_POS:Vector2 = -Vector2.INF
const NULL_GRID:Vector2i = -Vector2i.MAX

const MIN_BOUNCE_SPEED:float = 1.5
const MAX_PUSH:float = 5.0 
const PUSH_DECAY:float = 0.2
const VEL_DECAY:float = 0.1		# A faster entity could have problems when sprinting (this will be reavaluated afterward) 

# Terrain blocking is being reconsidered
const BIOME = TerrainSystem.BIOME

static func grid_to_world(posi:Vector2i)->Vector2:
	return Vector2(posi) * DIR.SCALE
static func world_to_grid(posf:Vector2)->Vector2i:
	return Vector2i(posf.x, posf.y) / DIR.SCALE
static func clamp_point(posf:Vector2)->Vector2:
	# Avoids having a margin at the top of the map where entities can't access
	return posf.clamp(-MovementComponent.HitboxSize[MovementComponent.Weight.TINY], DIR.SCALED_BOUNDS)

var _contact_cache:Array[Array] = []
var _overlapping:Dictionary[MovementComponent, Dictionary] = {}

func process()->void:
	_build_contact_cache()
	_separation_pass()
	for component:MovementComponent in _overlapping.keys():
		if _overlapping[component].get('delay', 0.0) > 0.0:
			component.velocity = Vector2.ZERO
			_overlapping[component]['delay'] -= DIR.delta
			if _overlapping[component].get('delay', 0.0) <= 0.0:
				_overlapping.erase(component)
	for movement:MovementComponent in DIR.request_all_components_of(MovementComponent):
		if movement.solid: continue		# Makes the solid entities passive
		if _overlapping.has(movement): continue
		
		_apply_movement(movement)
		_decay(movement)
## Builds the [member _contact_cache]. It should build it without pairing solids, or incomplete movement components.
func _build_contact_cache()->void:
	_contact_cache.clear()
	var all:Array = DIR.request_all_components_of(MovementComponent)
	for anchor:int in all.size():
		var anchor_mov:MovementComponent = all[anchor]
		if not anchor_mov.hitbox: continue
		
		var overlapping:Array[Area2D] = anchor_mov.hitbox.get_overlapping_areas()
		for other:int in range(anchor +1, all.size()):
			var other_mov:MovementComponent = all[other]
			if not other_mov.hitbox: continue
			if anchor_mov.type != other_mov.type: continue
			if anchor_mov.solid and other_mov.solid: continue
			if other_mov.hitbox in overlapping:
				_contact_cache.append([anchor_mov, other_mov])
func _drag(movement:MovementComponent, velocity:Vector2)->void:
	movement.position = _bound_movement(movement.position + velocity)
func _apply_movement(movement:MovementComponent)->void:
	if _overlapping.has(movement): return
	var intended:Vector2 = movement.position + movement.velocity + movement.push
	movement.position = _bound_movement(intended)
# TASK: terrain/biome implementation. The mechanic behind blocking certain entities from going into another, non-intended biome,
# will most likely be left behind, as it is sound to have a GROUND entity enter WATER, and have it drown, or swim

## Decays velocity and push per frame.
func _decay(movement:MovementComponent)->void:
	movement.push *= PUSH_DECAY
	movement.velocity *= VEL_DECAY
	if movement.push.length() < 0.1:
		movement.push = Vector2.ZERO
	if movement.velocity.length() < 0.1:
		movement.velocity = Vector2.ZERO

# --- Separation --- #

## Corrects overlaps between solid entities.
func _separation_pass()->void:
	for pair:Array in _contact_cache:
		var anchor:MovementComponent = pair.front()
		var other:MovementComponent = pair.back()
		_separate(anchor, other)
## Pushes two overlapping solid entities apart by the minimum separation vector.
## [class HealthComponent.Vitality] is taken in account, if both entities do have it,
## making the weaker entity move more than the stronger one.
func _separate(mov_a:MovementComponent, mov_b:MovementComponent)->void:
	var inv_direction:Vector2 = (mov_a.position - mov_b.position).normalized()
	var dirx:float = abs(inv_direction.x)
	var diry:float = abs(inv_direction.y)
	
	dirx = 1.0 * signf(inv_direction.x) if dirx >= 0.45 else 0.0
	diry = 1.0 * signf(inv_direction.y) if diry >= 0.45 else 0.0
	
	inv_direction = -Vector2(dirx, diry)
	
	if mov_a.solid:
		mov_b.push = Vector2.ZERO
		mov_b.velocity = Vector2.ZERO
		_overlapping[mov_b] = { 'delay': 0.05 }
		mov_b.position += inv_direction * 0.15
		return
	if mov_b.solid:
		mov_a.push = Vector2.ZERO
		mov_a.velocity = Vector2.ZERO
		_overlapping[mov_a] = { 'delay': 0.05 }
		mov_a.position += inv_direction * 0.15
		return
	
	var vit_a:float = _get_vitality(mov_a.uid)
	var vit_b:float = _get_vitality(mov_b.uid)
	var total:float = vit_a + vit_b
	var ratio_a:float = vit_a / total  # how much A dominates
	var ratio_b:float = vit_b / total  # how much B dominates

	# Each entity gets pushed in the inverse direction of the other
	# Stronger entity (higher ratio) pushes the weaker one more
	var dir_a:Vector2 = -inv_direction          # direction away from B
	var dir_b:Vector2 = inv_direction         # direction away from A

	mov_a.push += dir_a * ratio_b

	mov_b.push += dir_b * ratio_a
	
func _get_world_rect_at(movement:MovementComponent, alt_pos:Vector2 = NULL_POS)->Rect2:
	var size:Vector2 = MovementComponent.HitboxSize[movement.weight]
	var offset:Vector2 = DIR.SCALED_POINT
	offset.x *= 0.5
	offset.y -= size.y - 2
	if alt_pos != NULL_POS:
		return Rect2(alt_pos + offset, size)
	return Rect2(movement.position + offset, size)
func _get_movement(uid:int)->MovementComponent:
	return DIR.get_component(uid, MovementComponent)
## Easy clamp of movement.
func _bound_movement(final_value:Vector2)->Vector2:
	return clamp_point(final_value)
func _get_vitality(uid:int)->float:
	var health:HealthComponent = DIR.get_component(uid, HealthComponent)
	if not health: return 1.0
	return maxf(1.0, health.vitality.value)
