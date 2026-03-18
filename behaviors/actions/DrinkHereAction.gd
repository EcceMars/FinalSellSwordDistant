class_name DrinkHereAction
extends Behavior

func tick(_uid:int, behavior_component:BehaviorComponent = null)->Status:
	if not behavior_component: return Status.ABORTED
	if not behavior_component.get_behavior(): return Status.ABORTED
	
	var health:HealthComponent = behavior_component.get_health()
	if not health: return Status.ABORTED
	
	var movement:MovementComponent = behavior_component.get_movement()
	if not movement: return Status.ABORTED
	
	var TERSYS:TerrainSystem = DIR.get_system(TerrainSystem)
	if not TERSYS.is_water_adjacent(movement.position):
		return Status.ABORTED

	health.thirst.modify(health.thirst.limit * 0.5)
	behavior_component.blackboard.where_to = DIR.NULL_POS
	
	## TODO! Drinking animation
	var visual:VisualComponent = health.get_visual()
	if visual:
		visual.shake(0.15, 3.0)
		visual.burst(Color.CYAN, 5)
	change_animation(behavior_component, 'act')
	return Status.DONE
