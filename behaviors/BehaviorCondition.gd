## Decorator: adds conditions to behaviors
class_name BehaviorCondition
extends Behavior

var condition:Callable
var behavior:Behavior

func _init(if_condition:Callable, if_behavior:Behavior)->void:
	condition = if_condition
	behavior = if_behavior
func tick(uid:int, behavior_component:BehaviorComponent = null)->Status:
	if not condition.call():
		return Status.ABORTED
	return behavior.tick(uid, behavior_component)
func reset()->void:
	behavior.reset()
func _to_string()->String:
	var message:String = super()
	message += ": %s?" % condition.get_method()
	
	return message
