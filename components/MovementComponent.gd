## Manages entity movement, velocity accumulation, and collision shape.
## All movement processing should be handled by [MovementSystem].
class_name MovementComponent
extends BaseComponent

const BIOME = TerrainSystem.BIOME

## Entities movement layer. This is generally used for collision.
enum Type {
	NONE		=	0, 		## ERROR
	
	FLY		=	1,		## Airborne entities.
	GROUND	=	2,		## Common surface entities.
	PHASE	=	3,		## Ghosts and spirits.
	WATER	=	4		## Acquatic entities.
	}
## Size class. Used to get the hitbox size.
enum Weight {
	TINY,
	NORMAL,
	LARGE,
	GIANT
	}
## Describes the rectangle (size/end) of the collision area of the entities.
const HitboxSize:Dictionary[Weight, Vector2] = {
	Weight.TINY:		Vector2(4, 4),
	Weight.NORMAL:	Vector2(8, 6),
	Weight.LARGE:	Vector2(14, 10),
	Weight.GIANT:	Vector2(28, 20)
	}
# --- Data members --- #

## Weak reference to an [Area2D] node for collision calculation.
var _area:WeakRef = null
var hitbox:Area2D:
	get: return _area.get_ref()
## Accumulated movement per frame.
var velocity:Vector2 = Vector2.ZERO
## Push from collisions.
var push:Vector2 = Vector2.ZERO
## Movement layer.
var type:Type = Type.GROUND
## Size class, hitbox size reference.
var weight:Weight = Weight.NORMAL
## Reflects completelly push. Trees, rocks and structures usually use this flag.
var solid:bool = false
## Sprite facing direction.
var faces_right:bool = true

# --- Constructors --- #
func _init(id:int, _type:Type, _weight:Weight, _solid:bool)->void:
	super(id)
	type = _type
	weight = _weight
	solid = _solid
	_build_area()
func _build_area()->void:
	var a:Area2D = Area2D.new()
	a.name = "%04dArea" % uid
	a.collision_layer = type
	a.collision_mask = type if type != Type.PHASE else 0
	
	var shape:CollisionShape2D = CollisionShape2D.new()
	shape.z_index = 2
	var rect:RectangleShape2D = RectangleShape2D.new()
	
	var weight_hbox:Vector2 = HitboxSize[weight]
	rect.size = weight_hbox
	shape.position = DIR.SCALED_POINT

	shape.position.x *= 0.5
	shape.position.y -= weight_hbox.y - 2
	
	shape.shape = rect
	a.add_child(shape)
	DIR.SPRITES.add_child(a)
	_area = weakref(a)

# --- Interfacing --- #
## Current world position.
var position:Vector2:
	get:
		if not hitbox: return MovementSystem.NULL_POS
		return hitbox.global_position
	set(value):
		if not hitbox: return
		DIR.update_ent_position(uid, position, value)
		hitbox.global_position = value
## Current grid position, snapped to [member DIR.SCALE].
var in_grid:Vector2i:
	get: return MovementSystem.world_to_grid(position)
## For moving an entity normally. Dragging or teleporting are done through [MovementSystem]
func add_velocity(direction:Vector2)->void:
	var health:HealthComponent = get_health()
	var speed:float = 1.0
	if health:
		speed += (health.agility.value - 1) * 0.025
	velocity += direction * speed
func natural_biome(biome:BIOME)->bool: return true
## As [MovementComponent] has a [WeakRef] to the entity collision components, this facilitates destroying them.
func destroy()->void:
	if DIR.get_entities_at(in_grid):
		DIR._map.erase(in_grid)
	if hitbox:
		hitbox.queue_free()
