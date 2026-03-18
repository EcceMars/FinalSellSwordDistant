class_name WaitForAction
extends Behavior

var wait_time:float = 1.0

func _init(_time:float = wait_time)->void:
	wait_time = _time
func tick(_uid:int, behavior_component:BehaviorComponent = null)->Status:
	behavior_component.blackboard.animation = 'idle'
	behavior_component.blackboard.wait_for= wait_time
	return Status.DONE
