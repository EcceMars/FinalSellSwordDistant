@icon("res://assets/icons/component_icon.png")
class_name BaseComponent
extends RefCounted

enum CFLAG {
	NONE			=	0 << 0,
	
	BEHAVIOR		=	1 << 0,
	INFORMATION =	1 << 1,
	INVENTORY	=	1 << 2,
	ITEM			=	1 << 3,
	HEALTH		=	1 << 4,
	MATERIA		=	1 << 5,
	MEMORY		=	1 << 6,
	MOVEMENT		=	1 << 7,
	PERCEPTION	=	1 << 8,
	VISUAL		=	1 << 9
	}
static var _REGISTERED:Dictionary[GDScript, CFLAG] = {
	null:						CFLAG.NONE,
	BehaviorComponent:			CFLAG.BEHAVIOR,
	InformationComponent:		CFLAG.INFORMATION,
	InventoryComponent:			CFLAG.INVENTORY,
	ItemComponent:				CFLAG.ITEM,
	HealthComponent:				CFLAG.HEALTH,
	MateriaComponent:			CFLAG.MATERIA,
	MemoryComponent:				CFLAG.MEMORY,
	MovementComponent:			CFLAG.MOVEMENT,
	PerceptionComponent:			CFLAG.PERCEPTION,
	VisualComponent:				CFLAG.VISUAL
	}
var flag:CFLAG = CFLAG.NONE
var uid:int = -1
func _init(id:int)->void:
	assert(not id < 0, "%s" % self)
	uid = id
	_set_flag()
func _set_flag()->void: flag = _REGISTERED.get(get_script())
func update()->void: pass
func destroy()->void: pass
func _to_string()->String:
	return str(flag) + ": %s" % get_script().get_global_name()

func get_behavior(_uid:int = -1)->BehaviorComponent:
	if _uid < 0: return DIR.get_component(uid, BehaviorComponent)
	return DIR.get_component(_uid, BehaviorComponent)
func get_health(_uid:int = -1)->HealthComponent:
	if _uid < 0: return DIR.get_component(uid, HealthComponent)
	return DIR.get_component(_uid, HealthComponent)
func get_item(_uid:int = -1)->ItemComponent:
	if _uid < 0: return DIR.get_component(uid, ItemComponent)
	return DIR.get_component(_uid, ItemComponent)
func get_inventory(_uid:int = -1)->InventoryComponent:
	if _uid < 0: return DIR.get_component(uid, InventoryComponent)
	return DIR.get_component(_uid, InventoryComponent)
func get_materia(_uid:int = -1)->MateriaComponent:
	if _uid < 0: return DIR.get_component(uid, MateriaComponent)
	return DIR.get_component(_uid, MateriaComponent)
func get_memory(_uid:int = -1)->MemoryComponent:
	if _uid < 0: return DIR.get_component(uid, MemoryComponent)
	return DIR.get_component(_uid, MemoryComponent)
func get_movement(_uid:int = -1)->MovementComponent:
	if _uid < 0: return DIR.get_component(uid, MovementComponent)
	return DIR.get_component(_uid, MovementComponent)
func get_visual(_uid:int = -1)->VisualComponent:
	if _uid < 0: return DIR.get_component(uid, VisualComponent)
	return DIR.get_component(_uid, VisualComponent)

func get_system(system_class:GDScript)->BaseSystem: return DIR.get_system(system_class)
