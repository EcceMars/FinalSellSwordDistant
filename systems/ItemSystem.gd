class_name ItemSystem
extends BaseSystem

const M = MateriaComponent.Materia
const V = HealthComponent.Vitals
var EFFECTS:Dictionary[M, MateriaComponent.Effect] = {
	M.ANIMAL:	MateriaComponent.Effect.new({ V.HUNGER: 18.0, V.ENERGY: 5.0 }),
	M.FRUIT:		MateriaComponent.Effect.new({ V.HUNGER: 15.0, V.THIRST: 5.0, V.ENERGY: 1.0 }),
	M.HERB:		MateriaComponent.Effect.new({ V.HUNGER: 10.0, V.ENERGY: 5.0 }),
	M.PLANT:		MateriaComponent.Effect.new({ V.HUNGER: 6.0, V.ENERGY: 5.0 }),
	M.POISON:	MateriaComponent.Effect.new({ V.HUNGER: -5.0, V.ENERGY: -2.0 }),		# Instead of directly diminishing blood, poison should cause a poisoned status
	}

var CARRY_OFFSET:Vector2 = Vector2(0, DIR.SCALE)
## Carrier_uid -> Carried_item_id
var _carried_items:Dictionary[int, int] = {}

func process()->void:
	for carrier_id:int in _carried_items:
		var movement:MovementComponent = DIR.get_component(carrier_id, MovementComponent)
		var visual:VisualComponent = DIR.get_component(_carried_items[carrier_id], VisualComponent)
		if visual:
			visual.sprite.get_ref().position = movement.position + CARRY_OFFSET
## Picks an item and stores it at the inventory.
func pick_up(ent_id:int, item_id:int)->bool:
	var movement:MovementComponent = DIR.get_component(item_id, MovementComponent)
	var item:ItemComponent = _get_item(item_id)
	if not movement or not item:
		return false
	var inventory:InventoryComponent = DIR.get_component(ent_id, InventoryComponent)
	if not inventory or not inventory.check(): return false
	
	item.last_owner = item.owner_uid
	item.owner_uid = ent_id
	
	DIR.delete_component(item_id, MovementComponent)
	DIR.delete_component(item_id, VisualComponent)			# The sprite on the world should be deleted (or be hidden and reused when calling the inventory UI, which I believe is a bit more cumbersome than just loading the item again, as any inventory has just a few items)
	
	inventory.add(item_id)
	return true
## This is used to simulates animals carrying food, or workers with an in use (at hand) item.
func carry(ent_id:int, item_id:int)->bool:
	var movement:MovementComponent = DIR.get_component(item_id, MovementComponent)
	var item:ItemComponent = _get_item(item_id)
	if not movement or not item:
		return false
	
	item.last_owner = item.owner_uid
	item.owner_uid = ent_id
	
	DIR.delete_component(item_id, MovementComponent)
	_carried_items[ent_id] = item_id
	
	return true
## [param snap] serves the purpose of leaving a resource item at a building site, for example, or on a special structure (e.g. an altar).
func drop(item_id:int, position:Vector2, snap:bool = false)->void:
	var item:ItemComponent = _get_item(item_id)
	if not item or item.owner_uid < 0: return	# Item was either destroyed and not removed from memory, or was wrongly assigned to an inventory
	
	item.last_owner = item.owner_uid
	item.owner_uid = -1
	
	DIR.delete_component(item_id, MovementComponent)		# To make sure
	var movement:MovementComponent = EntityConstructor.add_movement(item_id, MovementComponent.Type.GROUND, MovementComponent.Weight.TINY, false, snap, position)
	DIR.add_component(item_id, movement, true)
	
	var temp:EntityTemplate = DIR.ENTITYSTORE.data_arr.get(item.template)
	if temp and temp.has_visual:
		var visual:VisualComponent = EntityConstructor.add_visual(item_id, temp.visual_sprite_frames)
		DIR.add_component(item_id, visual, true)
	
	# Should the bundle function happen here?
func consume(ent_id:int, item_id:int)->bool:
	if not DIR.is_valid_entity(ent_id): return false
	
	var item:ItemComponent = _get_item(item_id)
	if not item: return false
	
	var health:HealthComponent = DIR.get_component(ent_id, HealthComponent)			# There could be an entity that devours items (calling for animations etc, but doesn't actually have an health component)
	
	var materia:MateriaComponent = item.get_materia()
	if materia and health:
		var quality_scalar:float = float(item.quality) / float(ItemComponent.Quality.COMMON)
		for material:M in materia.materials:
			if not EFFECTS.has(material): continue
			
			var effect:MateriaComponent.Effect = EFFECTS[material]
			for vital_type:V in effect.vital_change:
				var amount:float = effect.vital_change[vital_type] * quality_scalar
				health.vitals[vital_type].modify(amount)
	
	var inventory:InventoryComponent = DIR.get_component(ent_id, InventoryComponent)
	if inventory: inventory.remove(item_id)
	
	var visual:VisualComponent = materia.get_visual(item_id)
	if visual:
		visual.shake()
		visual.burst(Color.RED)
		print("HERE")
	
	DIR.destroy_entity(item_id)
	
	return true
func drop_inventory(ent_id:int)->void:
	# Make a small range around the the dead entity and scatter items in it
	# Again, a bundle function should be called here
	
	pass
	
func _get_item(item_id:int)->ItemComponent:
	return DIR.get_component(item_id, ItemComponent)
