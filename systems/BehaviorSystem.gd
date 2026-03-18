class_name BehaviorSystem
extends BaseSystem

func process()->void:
	for behavior_component:BehaviorComponent in DIR.request_all_components_of(BehaviorComponent):
		behavior_component.update()
