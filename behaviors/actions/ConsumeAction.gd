class_name ConsumeAction
extends Behavior

var type_consume:ItemComponent.Type = ItemComponent.Type.CONSUMABLE

func tick(uid:int, behavior_component:BehaviorComponent = null)->Status:
	if not behavior_component: return Status.ABORTED
	
	var inventory:InventoryComponent = behavior_component.get_inventory()
	if not inventory: return Status.ABORTED
	
	var item_id:int = inventory.has_item_type(type_consume)
	if item_id < 0: return Status.ABORTED
	
	var item_sys:ItemSystem = get_item_sys()
	if item_sys.consume(uid, item_id):
		change_animation(behavior_component, 'act')
		return Status.DONE
	
	return Status.ABORTED
