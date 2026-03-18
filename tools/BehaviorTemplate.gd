@tool
@icon("res://assets/icons/behavior_icon.png")
class_name BehaviorTemplate
extends Resource

enum Strategy { CHAMPION, GUARD, FOLLOWER, PREDATOR, PREY, WANDERER, WORKER }

const BTYPE = BehaviorComponent.Type 

@export var behavior_type:BTYPE = BTYPE.PREY
@export var walk_radius:float = 12.0
@export var wait_time:float = 1.0

func build(behavior_component:BehaviorComponent)->Behavior:
	match behavior_type:
		BTYPE.CHAMPION:	return _build_player(behavior_component)
		BTYPE.PREY:		return _build_prey(behavior_component)
		BTYPE.FOLLOWER:	return _build_follower()
		
	return _build_wander()
func _build_player(_behavior_component:BehaviorComponent)->BehaviorSelector:
	var selector:BehaviorSelector = BehaviorSelector.new()
	var player_sequence:BehaviorSequence = BehaviorSequence.new(
		[
			ListenForInputAction.new()
		]
	)
	selector.list.append(player_sequence)
	return selector
func _build_predator(behavior_component:BehaviorComponent)->BehaviorSelector:
	var selector:BehaviorSelector = BehaviorSelector.new()
	var hunt:BehaviorSequence = BehaviorSequence.new(
		[
			BehaviorCondition.new(
				Callable(behavior_component, 'has_target'),
				BehaviorSequence.new()
			)
		]
	)
	selector.list = [hunt, _build_wander()]
	return selector
func _build_prey(behavior_component:BehaviorComponent)->BehaviorSelector:
	var selector:BehaviorSelector = BehaviorSelector.new()
	selector.priority = true
	selector.list = [
		BehaviorCondition.new(Callable(behavior_component, 'is_hungry'), _build_seek_food()),
		BehaviorCondition.new(Callable(behavior_component, 'is_thirsty'), _build_seek_water()),
		_build_wander()
		]
	return selector
func _build_wander()->Behavior:
	var shuffler:BehaviorShuffler = BehaviorShuffler.new()
	shuffler.list = [
		BehaviorSequence.new(
			[
				LookAction.new(),
				WanderAction.new(walk_radius),
				MoveToAction.new(),
				LookAction.new(),
				WaitForAction.new(wait_time)
			]),
		BehaviorSequence.new(
			[
				LookAction.new(),
				WaitForAction.new(wait_time)
			]),
		BehaviorSequence.new(
			[
				TurnAction.new(),
				LookAction.new(),
				WaitForAction.new(wait_time * 0.5)
			])
		]
	return BehaviorRepeater.new(shuffler)
func _build_seek_food()->BehaviorSelector:
	var selector:BehaviorSelector = BehaviorSelector.new()
	selector.priority = true
	
	# Attempt to eat from inventory
	var eat_from_inventory:BehaviorSequence = BehaviorSequence.new(
		[
			ConsumeAction.new(),
			WaitForAction.new(1.5)
		]
	)
	
	# Attempt to remember where there is food and go there
	var go_to_food:BehaviorSequence = BehaviorSequence.new(
		[
			RecallFoodAction.new(),
			MoveToAction.new(),
			PickUpAction.new()
		]
	)
	
	# Look around for food
	var search:BehaviorSequence = BehaviorSequence.new(
		[
			LookAction.new(),
			WanderAction.new(4.0),
			MoveToAction.new(),
			WaitForAction.new(0.5)
		]
	)
	
	selector.list = [eat_from_inventory, go_to_food, search]
	return selector
# TASK: still needs implementation
func _build_seek_water()->BehaviorSelector:
	var selector:BehaviorSelector = BehaviorSelector.new()
	selector.priority = true
	
	var drink_water:BehaviorSequence = BehaviorSequence.new(
		[
			DrinkHereAction.new(),
			WaitForAction.new(1.0)
		]
	)
	
	var go_to_water:BehaviorSequence = BehaviorSequence.new(
		[
			RecallWaterAction.new(),
			MoveToAction.new(),
			DrinkHereAction.new(),
			WaitForAction.new(1.5)
		]
	)
	
	# Look around for water
	var search:BehaviorSequence = BehaviorSequence.new(
		[
			LookAction.new(),
			WanderAction.new(4.0),
			MoveToAction.new(),
			WaitForAction.new(0.5)
		]
	)
	
	var look_around:BehaviorSequence = BehaviorSequence.new(
		[
			TurnAction.new(),
			LookAction.new(),
			WaitForAction.new(0.5)
		]
	)
	
	selector.list = [drink_water, go_to_water, search, look_around]
	return selector
func _build_follower()->BehaviorSelector:
	var selector:BehaviorSelector = BehaviorSelector.new()
	selector.priority = true
	
	var seek_and_go:BehaviorSequence = BehaviorSequence.new(
		[
			FollowAction.new(1),
			MoveToAction.new(),
			WaitForAction.new(0.4)
		]
	)
	
	selector.list = [seek_and_go]
	return selector
