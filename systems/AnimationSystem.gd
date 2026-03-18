class_name AnimationSystem
extends BaseSystem

static var _queued_animation:Dictionary[int, Dictionary] = {	-1:	{	'delay': 0.0, 'key': 'idle'	}	}

func process()->void:
	for uid:int in _queued_animation.keys():
		_queued_animation[uid].delay -= DIR.delta
		if _queued_animation[uid].delay <= 0.0:
			play_animation(uid, _queued_animation[uid].key)
			_queued_animation.erase(uid)
		
	for uid:int in DIR.get_entities_by(BaseComponent.CFLAG.VISUAL):
		var visual:VisualComponent = DIR.get_component(uid, VisualComponent)
		visual.update()
		if not visual.sprite.get_ref().is_playing():
			visual.sprite.get_ref().play('idle')

static func change_animation(uid:int, key:String, delay:float)->bool:
	var visual:VisualComponent = DIR.get_component(uid, VisualComponent)
	if not visual: return false
	if not visual.sprite.get_ref().sprite_frames.has_animation(key): return false
	
	_queued_animation[uid] = { 'delay': delay, 'key': key }
	return true
static func play_animation(uid:int, key:String)->void:
	var visual:VisualComponent = DIR.get_component(uid, VisualComponent)
	if not visual: return
	
	var anim_sprite:AnimatedSprite2D = visual.sprite.get_ref()
	if not anim_sprite or not anim_sprite.sprite_frames: return
	if not anim_sprite.sprite_frames.has_animation(key): return
	
	var one_shoot:bool = not anim_sprite.sprite_frames.get_animation_loop(key)
	if one_shoot:
		var delay:float = anim_sprite.sprite_frames.get_frame_count(key)
		change_animation(uid, key, delay)
		return
	visual.sprite.get_ref().play(key)
## TODO: NEED AN ANIMATION AFTER QUEUEING
static func play_animation_after(uid:int, key:String)->void:
	var visual:VisualComponent = DIR.get_component(uid, VisualComponent)
	if not visual: return
	if not visual.sprite.get_ref().sprite_frames.has_animation(key): return
	
	var delay:float = 0.0
	if visual.sprite.get_ref().is_playing():
		var current_frame:int = visual.sprite.get_ref().frame
		var current_animation:String = visual.sprite.get_ref().animation
		delay = (visual.sprite.get_ref().sprite_frames.get_frame_count(current_animation) -1 - current_frame)
	
	change_animation(uid, key, delay)
