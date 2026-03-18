class_name MoveToAction
extends Behavior

var tolerance:float = 0.1

func _init(_tolerance:float = tolerance)->void:
	tolerance = _tolerance * DIR.SCALE
func tick(uid:int, behavior:BehaviorComponent = null) -> Status:
	var movement:MovementComponent = get_movement(uid)
	if not movement: return Status.ABORTED

	var target_pos:Vector2 = behavior.blackboard.where_to
	if target_pos == DIR.NULL_POS: return Status.ABORTED

	var distance:float = movement.position.distance_to(target_pos)
	if distance < tolerance:
		behavior.blackboard.where_to = DIR.NULL_POS
		change_animation(behavior, 'idle', true)
		return Status.DONE

	#DIR.DEBUG.draw_arrow(movement.position, target_pos, Color.BLUE, 1.0)
	var direction:Vector2 = movement.position.direction_to(target_pos)
	movement.add_velocity(direction)
	behavior.blackboard.animation = 'walk'
	if direction.x != 0.0:
		movement.faces_right = direction.x > 0
	return Status.RUNNING
func _to_string()->String:
	return get_script().get_global_name()
