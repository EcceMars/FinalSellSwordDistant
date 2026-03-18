class_name EntityInfoPanel
extends PanelContainer

var uid:int = -1

var name_label:Label
var attr_label:Label
var vital_label:Label
var has_health:bool = false
var species_label:Label
var has_specie:bool = false
var UID_label:Label
var action_label:Label
var has_behav:bool = false

var _preview:AnimatedSprite2D = null

func _ready()->void:
	theme = PixelTheme.create()
	anchor_left = 0.0
	anchor_right = 0.2		# I lowered this as the HBoxContainer spred the sprite from 
	anchor_top = 1.0
	anchor_bottom = 1.0
	offset_top = -96
	offset_bottom = -8
	
	grow_vertical = Control.GROW_DIRECTION_BEGIN
	
	var hbox:HBoxContainer = HBoxContainer.new()
	add_child(hbox)
	
	# TASK! This works for the smaller sprites, but the trees (48x48) get out of the screen, maybe a container.
	# I could have messed up the configurations
	_preview = AnimatedSprite2D.new()
	_preview.centered = false
	_preview.scale = Vector2.ONE * 4
	hbox.add_child(_preview)
	
	hbox.add_spacer(true)
	
	var vbox:VBoxContainer = VBoxContainer.new()
	hbox.add_child(vbox)
	
	name_label = _make_label(vbox, 10)
	attr_label = _make_label(vbox)
	vital_label = _make_label(vbox)
	species_label = _make_label(vbox)
	UID_label = _make_label(vbox)
	action_label = _make_label(vbox)
	hide()
func show_entity(_uid:int)->void:
	if _uid < 0:
		hide()
		return
	uid = _uid
	_force_sync_sprite()
	_refresh()
	show()
func update()->void:
	if not visible or uid < 0: return
	_refresh()
	
	_refer_to_sprite()
		
func _refresh()->void:
	var information:InformationComponent = DIR.get_component(uid, InformationComponent)
	if not information: return
	
	name_label.text = information.name + (" | " + information.gender) if information.gender else information.name 
	
	var health:HealthComponent = DIR.get_component(uid, HealthComponent)
	if health:
		species_label.text = "Species: %s" % HealthComponent.Species.keys()[health.specie]
		attr_label.text = "Agi: %d\nMnd: %d\nSpr: %d\nVit: %d" % [
			health.agility.value, health.mind.value, health.spirit.value, health.vitality.value]
		vital_label.text = "Bld:%.0f%%\nHgr:%.0f%%\nThr:%.0f%%\nEng:%.0f%%" % [
			health.blood.ratio() * 100,
			health.hunger.ratio() * 100,
			health.thirst.ratio() * 100,
			health.energy.ratio() * 100
		]
	else:
		species_label.text = "NO_SPECIE"
		attr_label.text = "NO_ATT"
	var behavior:BehaviorComponent = DIR.get_component(uid, BehaviorComponent)
	if behavior:
		action_label.text = "Action: %s" % information.action
	_refer_to_sprite()
	
	UID_label.text = "UID: %d" % uid
func _make_label(parent:Control, font_size:int = 10)->Label:
	var label:Label = Label.new()
	label.add_theme_font_size_override('font_size', font_size)
	parent.add_child(label)
	
	return label
# I made this so to not repeat the code for grabing the sprite reference
# Then, animation doesn't update. For example, when I click at the trees that, from time to time,
# play a 'wind' animation, and wave a bit.
func _refer_to_sprite()->void:
	var visual:VisualComponent = DIR.get_component(uid, VisualComponent)
	if visual:
		var ref_sprite:AnimatedSprite2D = visual.sprite.get_ref()
		if ref_sprite and _preview.animation != ref_sprite.animation:
			_preview.sprite_frames = ref_sprite.sprite_frames
			_preview.play(ref_sprite.animation)
			var tex_size:Vector2 = ref_sprite.sprite_frames.get_frame_texture(ref_sprite.animation, ref_sprite.frame).get_size()
			var scale_factor: float = min(16.0, 96.0 / max(tex_size.x, tex_size.y))
			_preview.scale = Vector2.ONE * scale_factor
			_preview.position = _preview.scale * 0.5
			_preview.flip_h = ref_sprite.flip_h
func _force_sync_sprite() -> void:
	var visual:VisualComponent = DIR.get_component(uid, VisualComponent)
	if not visual: return
	var ref_sprite:AnimatedSprite2D = visual.sprite.get_ref()
	if not ref_sprite: return

	var tex_size:Vector2 = ref_sprite.sprite_frames.get_frame_texture(ref_sprite.animation, 0).get_size()
	_preview.scale = Vector2.ONE * min(16.0, 96.0 / max(tex_size.x, tex_size.y))
	_preview.position = _preview.scale * 0.5
	_preview.sprite_frames = ref_sprite.sprite_frames
	_preview.flip_h = ref_sprite.flip_h
	_preview.play(ref_sprite.animation)
