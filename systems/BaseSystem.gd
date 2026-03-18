@icon("res://assets/icons/system_icon.png")
class_name BaseSystem
extends Object

const CFLAG = BaseComponent.CFLAG

enum SFLAG {
	NONE			=	0 << 0,
	
	ACT				=	1 << 0,
	ANIMATION		=	1 << 1,
	BEHAVIOR		=	1 << 2,
	HEALTH			=	1 << 3,
	INFORMATION		=	1 << 4,
	ITEM			=	1 << 5,
	MOVEMENT		=	1 << 6,
	RENDER			=	1 << 7,
	TERRAIN			=	1 << 8
	}
static var _REGISTRY:Dictionary[GDScript, SFLAG] = {
	#EntitySystem:					SFLAG.ENTITY,
	AnimationSystem:				SFLAG.ANIMATION,
	BehaviorSystem:					SFLAG.BEHAVIOR,
	InformationSystem:				SFLAG.INFORMATION,
	ItemSystem:						SFLAG.ITEM,
	HealthSystem:					SFLAG.HEALTH,
	MovementSystem:					SFLAG.MOVEMENT,
	RenderSystem:					SFLAG.RENDER,
	TerrainSystem:					SFLAG.TERRAIN
	}
var flag:SFLAG = SFLAG.NONE
func _init(..._sys_params:Array)->void:
	_set_flag()
func _set_flag()->void:
	flag = _REGISTRY.get(get_script())
func process()->void: pass
func _to_string()->String:
	return get_script().get_global_name()
