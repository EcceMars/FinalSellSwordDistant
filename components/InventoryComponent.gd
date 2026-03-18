## This component provides an entity a few slots to carry item type entities.
## Very few entities don't have an inventory (object, item or phenomena entities most likely).
class_name InventoryComponent
extends BaseComponent

const Type = ItemComponent.Type

var list:Array[int] = []
var capacity:int = 3

func _init(id:int, _capacity:int = capacity)->void:
	super(id)
	capacity = _capacity

func add(item_id:int)->void:
	# Should DIR.is_valid_entity be used?
	if not DIR.is_valid_entity(item_id): return
	
	if check(): list.append(item_id)
func remove(item_id:int)->void: list.erase(item_id)
## This functions serves both as a check and a getter
func has_item_type(item_type:Type)->int:
	for item_id:int in list:
		var item:ItemComponent = get_item(item_id)
		if item.type == item_type:
			return item_id
	return -1
func has_item_of_material(material:MateriaComponent.Materia)->int:
	for item_id:int in list:
		var materia:MateriaComponent = get_materia(item_id)
		if not materia: continue
		
		if material in materia.materials:
			return item_id
	return -1
## Checks if the capacity limit of the inventory has not been reached.
func check()->bool: return list.size() < capacity
