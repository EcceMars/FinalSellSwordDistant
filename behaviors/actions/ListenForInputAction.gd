## Takes the input of the player and passes it down to the blackboard, applying it when needed
class_name ListenForInputAction
extends Behavior

const INPUT_DEAD_ZONE:float = 0.03
var input_frame:float = 0.0

var action_timer:float = 0.0

func tick(_uid:int, behavior_component:BehaviorComponent = null)->Status:
	if action_timer > 0.0:
		action_timer -= DIR.delta
		return Status.RUNNING
	var movement:MovementComponent = behavior_component.get_movement()
	if not movement: return Status.ABORTED
	
	if Input.is_action_just_released("enable_cam_follow"):
		DIR.CAM_MANAGER.follow_enabled = !DIR.CAM_MANAGER.follow_enabled
	
	if Input.is_action_just_released("interact"):
		behavior_component.blackboard.animation = 'act'
		behavior_component.blackboard.wait_animation = false		# Act is immediate
		action_timer = 0.3
		return Status.RUNNING
	
	var input_dir:Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir == Vector2.ZERO:
		input_frame = 0.0
		behavior_component.blackboard.wait_animation = true		# Makes the entity seem like it is stopping from movement
		behavior_component.blackboard.animation = 'idle'
		return Status.RUNNING
	
	input_frame += DIR.delta
	if input_dir.x != 0.0:
		movement.faces_right = input_dir.x > 0

	if input_frame >= INPUT_DEAD_ZONE:
		movement.add_velocity(input_dir)
		behavior_component.blackboard.animation = 'walk'
	else:
		behavior_component.blackboard.animation = 'idle'
	return Status.RUNNING
