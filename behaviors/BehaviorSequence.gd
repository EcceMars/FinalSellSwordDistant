## Sequence routine: all behaviors must succed
class_name BehaviorSequence
extends Behavior

var list:Array[Behavior] = []
var current:int = 0

func _init(param_behaviors:Array[Behavior] = list)->void:
	list = param_behaviors
func tick(uid:int, behavior_component:BehaviorComponent = null)->Status:
	if list.is_empty(): return Status.DONE
	
	while current < list.size():
		var result:Status = list[current].tick(uid, behavior_component)
		match(result):
			Status.RUNNING: return Status.RUNNING
			Status.DONE: current += 1
			Status.ABORTED:
				reset()
				return Status.ABORTED
	reset()
	return Status.DONE
func reset()->void:
	current = 0
	for behavior:Behavior in list:
		behavior.reset()
func _to_string()->String:
	var message:String = super()
	for behavior:Behavior in list:
		message += "\n\t" + str(behavior)
		
	return message
