class_name VisualComponent
extends BaseComponent

const MIN_HIT_SIZE:Vector2 = Vector2(16, 16)
var sprite:WeakRef = null

func _init(id:int, sprite_frames:SpriteFrames)->void:
	super(id)
	var anim_sprite:AnimatedSprite2D = AnimatedSprite2D.new()
	anim_sprite.name = "%04dSprite" % uid
	anim_sprite.sprite_frames = sprite_frames
	anim_sprite.centered = false
	sprite = weakref(anim_sprite)
	sprite.get_ref().offset = _offset()
	sprite.get_ref().play('idle')

func destroy()->void:
	sprite.get_ref().queue_free()

func shake(duration:float = 0.25, intensity:float = 5.0)->void:
	var ref_sprite:AnimatedSprite2D = sprite.get_ref()
	if not ref_sprite or not ref_sprite.is_inside_tree(): return
	var original:Vector2 = ref_sprite.position
	var tween:Tween = ref_sprite.create_tween()
	var steps:int = int(duration / 0.05)
	for i:int in steps:
		var offset:Vector2 = Vector2(randf_range(-intensity, intensity), 0.0)
		tween.tween_property(ref_sprite, 'position', original + offset, 0.05)
	tween.tween_property(ref_sprite, 'position', original, 0.08)
func burst(color: Color = Color.WHITE, amount: int = 8) -> void:
	var ref_sprite:AnimatedSprite2D = sprite.get_ref()
	if not ref_sprite or not ref_sprite.is_inside_tree(): return
	var particles:GPUParticles2D = GPUParticles2D.new()
	var material:ParticleProcessMaterial = ParticleProcessMaterial.new()
	material.color = color
	material.direction = Vector3(0, -1, 0)
	material.spread = 180.0
	material.gravity = Vector3(0, 200, 0)
	material.initial_velocity_min = 50.0
	material.initial_velocity_max = 100.0
	material.scale_min = 0.5
	material.scale_max = 1.5
	particles.process_material = material
	particles.amount = amount
	particles.explosiveness = 1.0
	particles.one_shot = true
	particles.lifetime = 0.8
	particles.position = ref_sprite.position + Vector2(8, 8)
	DIR.SPRITES.add_child(particles)
	particles.emitting = true
	await DIR.SPRITES.get_tree().create_timer(particles.lifetime + 0.1).timeout
	particles.queue_free()

func contains_point(point:Vector2)->bool:
	var ref_sprite:AnimatedSprite2D = sprite.get_ref()
	if not ref_sprite: return false
	
	var texture_size:Vector2 = _current_texture_size(ref_sprite)
	var hit_size:Vector2 = texture_size.max(MIN_HIT_SIZE)
	
	var visual_centroid:Vector2 = ref_sprite.global_position + _offset() + texture_size * 0.5
	var top_left:Vector2 = visual_centroid - hit_size * 0.5
	var bounds:Rect2 = Rect2(top_left, hit_size)
	return bounds.has_point(point)
func _offset()->Vector2:
	var ref_sprite:AnimatedSprite2D = sprite.get_ref()
	var texture_size:Vector2 = _current_texture_size(ref_sprite)
	if texture_size.y <= DIR.SCALE and texture_size.x <= DIR.SCALE: return Vector2.ZERO
	# TODO: check for texture_size.x
	var y_off:float = texture_size.y / float(DIR.SCALE)
	y_off -= 1
	var x_off:float = y_off * 0.5
	return -Vector2(x_off, y_off) * DIR.SCALE
func _current_texture_size(ref_sprite:AnimatedSprite2D)->Vector2:
	return ref_sprite.sprite_frames.get_frame_texture(ref_sprite.animation, ref_sprite.frame).get_size()
