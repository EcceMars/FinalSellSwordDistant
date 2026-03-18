class_name InformationSystem
extends BaseSystem

const LABEL_OFFSET:Vector2 = Vector2(-8, -20)
var _labels:Dictionary[int, WeakRef] = {}

func instance()->void:
	for info:InformationComponent in DIR.request_all_components_of(InformationComponent):
		if _labels.has(info.uid): continue
		
		var panel:PanelContainer = PanelContainer.new()
		panel.theme = PixelTheme.create()
		panel.z_index += 1
		
		var label:Label = Label.new()
		label.add_theme_font_size_override("font_size", 8)
		panel.add_child(label)
		
		DIR.DEBUG.add_child(panel)
		_labels[info.uid] = weakref(panel)

func process()->void:
	for info:InformationComponent in DIR.request_all_components_of(InformationComponent):
		var ref:WeakRef = _labels.get(info.uid)
		if not ref: continue

		var panel:PanelContainer = ref.get_ref()
		if not panel: continue

		var movement:MovementComponent = DIR.get_component(info.uid, MovementComponent)
		if not movement: continue
		
		var label:Label = panel.get_child(0)
		label.text = "%s | %s" % [info.name, info.action]
		panel.position = movement.position + LABEL_OFFSET
func destroy(uid:int) -> void:
	var ref:WeakRef = _labels.get(uid)
	if ref:
		var label = ref.get_ref()
		if label: label.queue_free()
	_labels.erase(uid)
