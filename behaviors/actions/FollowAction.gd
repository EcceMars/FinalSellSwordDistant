## (Previously the ComeCloserToAction) This will be treated as a debug action for the follower behavior type.
class_name FollowAction
extends Behavior

## UID to follow.
var who:int = -1

func _init(_who:int)->void:
	who = _who
func tick(uid:int, behavior:BehaviorComponent = null)->Status:
	var movement:MovementComponent = get_movement(uid)
	if not movement: return Status.ABORTED

	var who_movement:MovementComponent = get_movement(who)
	if not who_movement: return Status.ABORTED
	
	var target_pos:Vector2 = who_movement.position
	if target_pos == DIR.NULL_POS: return Status.ABORTED

	DIR.DEBUG.draw_arrow(movement.position, target_pos, Color.RED, 1.0)
	
	var half_distance:float = movement.position.distance_to(who_movement.position) * 0.5
	if half_distance < 2 * DIR.SCALE:
		behavior.blackboard.where_to = movement.position
		return Status.DONE
	behavior.blackboard.where_to = movement.position.move_toward(who_movement.position, half_distance)
	
	return Status.DONE
func _to_string()->String:
	return get_script().get_global_name()
