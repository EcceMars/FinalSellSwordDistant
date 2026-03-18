class_name TurnAction
extends Behavior

func tick(uid:int, behavior_component:BehaviorComponent = null)->Status:
	var mov:MovementComponent = get_movement(uid)
	if not mov: return Status.ABORTED
	
	behavior_component.blackboard.animation = 'idle'
	mov.faces_right = !mov.faces_right
	
	return Status.DONE
