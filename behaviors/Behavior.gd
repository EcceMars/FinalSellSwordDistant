## Base behavior class for the behavior tree/GOAP system.
class_name Behavior
extends RefCounted

## Action/routine status. While [enum Status.DONE] and [enum Status.RUNNING] are descriptive,
## [enum Status.ABORTED] can describe either a failed or externally aborted action.
enum Status {	DONE, RUNNING, ABORTED	}

func tick(_uid:int, _behavior_component:BehaviorComponent = null)->Status: return Status.DONE
func reset()->void:pass

func get_health(uid:int)->HealthComponent:
	return DIR.get_component(uid, HealthComponent)
func get_inventory(uid:int)->InventoryComponent:
	return DIR.get_component(uid, InventoryComponent)
func get_memory(uid:int)->MemoryComponent:
	return DIR.get_component(uid, MemoryComponent)
func get_movement(uid:int)->MovementComponent:
	return DIR.get_component(uid, MovementComponent)
func get_perception(uid:int)->PerceptionComponent:
	return DIR.get_component(uid, PerceptionComponent)
func get_item_sys()->ItemSystem:
	return DIR.get_system(ItemSystem)
func get_terra_sys()->TerrainSystem:
	return DIR.get_system(TerrainSystem)
func is_valid_position(position:Vector2)->bool:
	if position.x < 0: return false
	if position.y < 0: return false
	if position.x >= DIR.SCALED_BOUNDS.x: return false
	if position.y >= DIR.SCALED_BOUNDS.y: return false
	
	return true
func change_animation(behav_component:BehaviorComponent, key:String, wait:bool = false)->void:
	behav_component.blackboard.animation = key
	behav_component.blackboard.wait_animation = wait

func _to_string()->String:
	return get_script().get_global_name()
