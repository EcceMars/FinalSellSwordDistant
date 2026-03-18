class_name PickUpAction
extends Behavior

func tick(uid:int, behavior_component:BehaviorComponent = null)->Status:
	if not behavior_component: return Status.ABORTED
	
	var movement:MovementComponent = behavior_component.get_movement()
	if not movement: return Status.ABORTED
	
	var nearby:Array = DIR.get_entities_near(movement.in_grid, 1)
	for candidate:int in nearby:
		var item:ItemComponent = DIR.get_component(candidate, ItemComponent)
		# Skipping ownage of items as a thieving will be common until a system is built to prevent it for some entities
		if not item: continue
		
		var item_sys:ItemSystem = get_item_sys()
		if item_sys.pick_up(uid, candidate):
			behavior_component.blackboard.mem_entry = null
			return Status.DONE
	return Status.ABORTED
