## Decorator: repeats a behavior
class_name BehaviorRepeater
extends Behavior

var behavior:Behavior = null
var times:int = -1				## A negative value will make the behavior repeat until aborted
var counter:int = 0

func _init(_behavior:Behavior, _times:int = times)->void:
	behavior = _behavior
	times = _times
func tick(uid:int, behavior_component:BehaviorComponent = null)->Status:
	while times == -1 or counter < times:
		var result:Status = behavior.tick(uid, behavior_component)
		match(result):
			Status.RUNNING:
				return Status.RUNNING
			Status.DONE:
				counter += 1
				behavior.reset()
				if times != -1 and counter >= times:
					reset()
					return Status.DONE
				return Status.RUNNING
			Status.ABORTED:
				reset()
				return Status.ABORTED
	reset()
	return Status.DONE
func reset()->void:
	counter = 0
	behavior.reset()
func _to_string()->String:
	var message:String = super() + " -> "
	message += str(behavior) + ": \ttimes: %d | counter: %d" % [times, counter]
	return message
