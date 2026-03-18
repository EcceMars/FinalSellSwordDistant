@icon("res://assets/icons/entity_icon.png")
class_name EntityConstructor
extends RefCounted

const AType = EntityStore.Archetypes

static func spawn_entity()->int:
	var uid:int = DIR._request_uid()
	DIR.register_entity(uid)
	return uid
static func spawn_type(archetype:AType, point:Vector2 = DIR.NULL_POS)->int:
	var uid:int = spawn_entity()
	var entity:EntityTemplate = null
	
	entity = DIR.ENTITYSTORE.get_and_load(archetype)
	
	if entity.has_behavior:
		add_behavior(
			uid,
			entity.behavior_tree
		)
	if entity.has_health:
		const ATT = HealthComponent.Attributes
		add_health(uid, {
			'health_specie': entity.health_specie,
			'health_attributes': {
				ATT.AGILITY: entity.health_agility,
				ATT.MIND: entity.health_mind,
				ATT.SPIRIT: entity.health_spirit,
				ATT.VITALITY: entity.health_vitality
			}
		})
	if entity.has_information:
		add_information(uid, entity)
	if entity.has_inventory:
		add_inventory(uid, entity.inventory_capacity)
	if entity.is_item:
		add_item(uid, entity.template_name, entity.item_type, entity.item_quality, entity.item_quantity, entity.item_owner_uid, entity.item_last_owner)
	if entity.has_materia:
		add_materia(uid, entity.materia_essence, entity.materia_composition)
	if entity.has_memory:
		add_memory(uid)
	if entity.has_movement:
		if entity.movement_point != DIR.NULL_POS:
			point = entity.movement_point
		add_movement(uid, entity.movement_type, entity.movement_weight, entity.movement_solid, entity.movement_snap, point)
	if entity.has_perception:
		add_perception(uid, entity)
	if entity.has_visual:
		add_visual(uid, entity.visual_sprite_frames)
	return uid
static func add_behavior(uid:int, tree_template:BehaviorTemplate)->BehaviorComponent:
	var behavior_component:BehaviorComponent = BehaviorComponent.new(uid)
	if tree_template:
		behavior_component.root_behavior = tree_template.build(behavior_component)
		
	return DIR.add_component(uid, behavior_component)
## [param stat_data] can be passed as empty, althought it shouldn't be.
## It is configured in this way:
## stat_data.specie: [enum HealthComponent.Species]
## attributes: { [enum HealthComponent.Attributes]: [int] }
static func add_health(uid:int, stat_data:Dictionary)->HealthComponent:
	const ATT = HealthComponent.Attributes
	const STANDARD_STAT_DATA:Dictionary = {
		'health_specie':					HealthComponent.Species.ANIMAL,
		
		'health_attributes' : {
			ATT.AGILITY:												0,
			ATT.MIND:												0,
			ATT.SPIRIT:												0,
			ATT.VITALITY:											1
			},
		}
	stat_data.merge(STANDARD_STAT_DATA)
	
	var health:HealthComponent = HealthComponent.new(uid, stat_data)
	return DIR.add_component(uid, health)
static func add_information(uid:int, entity:EntityTemplate)->InformationComponent:
	var ent_name:String = entity.info_name
	if entity.info_name == "":
		ent_name = entity.template_name
	var information:InformationComponent = InformationComponent.new(uid, ent_name, entity.info_gender)

	return DIR.add_component(uid, information)
static func add_inventory(uid:int, capacity:int)->InventoryComponent:
	return DIR.add_component(uid, InventoryComponent.new(uid, capacity))
static func add_item(uid:int, template_name:String, type:ItemComponent.Type, quality:ItemComponent.Quality = ItemComponent.Quality.COMMON, quantity:int = 1, owner_uid:int = -1, last_owner_uid:int = -1)->ItemComponent:
	var item:ItemComponent = ItemComponent.new(uid)
	item.template = template_name
	item.type = type
	item.quality = quality
	item.quantity = quantity
	item.owner_uid = owner_uid
	item.last_owner = last_owner_uid
	
	return DIR.add_component(uid, item)
static func add_materia(uid:int, essence:MateriaComponent.Essence, composition:Array[MateriaComponent.Materia])->MateriaComponent:
	var materia:MateriaComponent = MateriaComponent.new(uid, essence, composition)
	
	return DIR.add_component(uid, materia)
static func add_memory(uid:int)->MemoryComponent:
	return DIR.add_component(uid, MemoryComponent.new(uid))
static func add_movement(uid:int, type:MovementComponent.Type, weight:MovementComponent.Weight, solid:bool, snap:bool = true, point:Vector2 = DIR.NULL_POS)->MovementComponent:
	var movement:MovementComponent = MovementComponent.new(uid, type, weight, solid)
	movement.weight = weight
	if point == DIR.NULL_POS:
		point = DIR.rand_restricted(movement) * DIR.SCALE
	if snap:
		point = Vector2(MovementSystem.world_to_grid(point))
	movement.position = point

	return DIR.add_component(uid, movement)
static func add_perception(uid:int, entity:EntityTemplate)->PerceptionComponent:
	var perception:PerceptionComponent = PerceptionComponent.new(uid)
	perception.attention_limit = entity.percep_attention_limit
	perception.debug = entity.percep_debug
	perception.forward_ratio = entity.percep_forward_ratio
	perception.max_attempts = entity.percep_max_attempts
	perception.scan_pattern = entity.percep_scan_pattern
	perception.scan_speed = entity.percep_scan_speed
	perception.vision_range = entity.percep_vision_range
	
	return DIR.add_component(uid, perception)
static func add_visual(uid:int, sprite_frames:SpriteFrames)->VisualComponent:
	var visual:VisualComponent = VisualComponent.new(uid, sprite_frames)
	DIR.add_component(uid, visual)
	DIR.SPRITES.add_child(visual.sprite.get_ref())
	return visual
