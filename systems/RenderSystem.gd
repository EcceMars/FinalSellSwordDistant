class_name RenderSystem
extends BaseSystem

func process()->void:
	for uid:int in DIR.get_entities_by(CFLAG.MOVEMENT | CFLAG.VISUAL):
		var movement:MovementComponent = DIR.get_component(uid, MovementComponent)
		var visual:VisualComponent = DIR.get_component(uid, VisualComponent)
		visual.sprite.get_ref().position = movement.position
		visual.sprite.get_ref().flip_h = not movement.faces_right
