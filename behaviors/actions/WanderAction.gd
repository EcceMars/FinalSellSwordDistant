class_name WanderAction
extends Behavior

var radius:float = 1.0

func _init(in_range:float = radius)->void:
	radius = in_range
func tick(uid:int, behavior_component:BehaviorComponent = null)->Status:
	var movement:MovementComponent = get_movement(uid)
	if not movement: return Status.ABORTED
	
	var scaled_range:float = radius * DIR.SCALE
	var current_pos:Vector2 = movement.position

	for attempt:int in 10:  # try up to 10 random targets
		var xoff:float = randf_range(-scaled_range, scaled_range)
		var yoff:float = randf_range(-scaled_range, scaled_range)
		var target_pos:Vector2 = MovementSystem.clamp_point(
			Vector2(current_pos.x + xoff, current_pos.y + yoff)
		)
		var grid_pos:Vector2i = MovementSystem.world_to_grid(target_pos)
		
		var blocked:bool = false
		for other:int in DIR.get_entities_at(grid_pos):
			if other == uid: continue
			var alt_mov: MovementComponent = DIR.get_component(other, MovementComponent)
			if alt_mov and alt_mov.solid:
				blocked = true
				break
		
		if not blocked:
			behavior_component.blackboard.where_to = target_pos
			return Status.DONE
		
	behavior_component.blackboard.where_to = current_pos
	#change_animation(behavior_component, 'idle')
	return Status.DONE
