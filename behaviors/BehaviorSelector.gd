## Runs until one of the behaviors succed
class_name BehaviorSelector
extends Behavior

var list:Array[Behavior] = []
var current:int = 0
var priority:bool = true

func tick(uid:int, behavior_component:BehaviorComponent = null)->Status:
	if list.is_empty(): return Status.ABORTED
	if priority: current = 0
	
	while current < list.size():
		var result:Status = list[current].tick(uid, behavior_component)
		match(result):
			Status.RUNNING: return Status.RUNNING
			Status.DONE:
				reset()
				return Status.DONE
			Status.ABORTED:
				current += 1
	reset()
	return Status.ABORTED
func reset()->void:
	current = 0
	for behavior:Behavior in list:
		behavior.reset()
func _to_string()->String:
	var message:String = super()
	for behavior:Behavior in list:
		message += "\n\t" + str(behavior)
	return message
