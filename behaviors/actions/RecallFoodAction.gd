class_name RecallFoodAction
extends Behavior

const MT = MemoryComponent.Type

func tick(uid:int, behavior_component:BehaviorComponent = null)->Status:
	var memory:MemoryComponent = get_memory(uid)
	if not memory: return Status.ABORTED
	
	var entry:MemoryComponent.Memory = behavior_component.blackboard.mem_entry
	# If previously, the LookAction found food
	if entry and entry.type == MT.FOOD:
		behavior_component.blackboard.where_to = behavior_component.blackboard.mem_entry.position
		return Status.DONE
	
	var best:MemoryComponent.Memory = memory.remember_closer(MT.FOOD)
	if not best: return Status.ABORTED
	
	behavior_component.blackboard.where_to = best.position
	behavior_component.blackboard.mem_entry = best

	return Status.DONE
