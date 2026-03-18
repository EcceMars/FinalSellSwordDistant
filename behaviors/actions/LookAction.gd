## Makes the entity 'perceive' a certain range to the front of it.
class_name LookAction
extends Behavior

const MT = MemoryComponent.Type

func tick(uid:int, behavior_component:BehaviorComponent = null)->Status:
	var perception:PerceptionComponent = get_perception(uid)
	if not perception: return Status.DONE					# Some simpler entities may use behaviors that usually work with perception, while not having such component
	
	var catch:Array[PerceptionComponent.RayResult] = perception.look()
	if catch.is_empty(): return Status.DONE
	
	var memory:MemoryComponent = perception.get_memory()
	for result:PerceptionComponent.RayResult in catch:
		if memory:
			var mem_type:MT = memory.classify(result)
			var new_entry:MemoryComponent.Memory = memory.update_memory(result.hit_entity, mem_type, result.hit_point)
			_push_memory(new_entry, behavior_component)
		# Fallback for entities without memory
		else:
			if result.raw_data == 'water':
				behavior_component.blackboard.water_location = result.hit_point
	return Status.DONE
func _push_memory(entry:MemoryComponent.Memory, behavior_component:BehaviorComponent)->void:
	match(entry.type):
		MT.FOOD:
			behavior_component.blackboard.mem_entry = entry
		MT.ENEMY:
			behavior_component.blackboard.enemy = entry.who
		MT.PREY:
			behavior_component.blackboard.target_entity = entry.who
		MT.MATE:
			behavior_component.blackboard.friend = entry.who
		MT.WATER:
			behavior_component.blackboard.water_location = entry.position
func _to_string()->String:
	return get_script().get_global_name()
