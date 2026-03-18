## Picks a random behavior from a given list. Use this to chain sequences in a more randomized way,
## where order or data sharing between behaviors doesn't matter.
class_name BehaviorShuffler
extends Behavior

var list:Array[Behavior] = []
var _current:Behavior = null

func tick(uid:int, behavior_component:BehaviorComponent = null)->Status:
	if list.is_empty(): return Status.ABORTED
	
	if not _current:
		_current = list.pick_random()
	
	var result:Status = _current.tick(uid, behavior_component)
	if result == Status.RUNNING:
		return result
	reset()
	return result
func reset()->void:
	if _current:
		_current.reset()
		_current = null
