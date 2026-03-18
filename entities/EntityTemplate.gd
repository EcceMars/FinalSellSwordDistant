@tool
@icon("res://assets/icons/entity_icon.png")
class_name EntityTemplate
extends Resource

@export var template_name:String = "Unnamed"
@export var icon:Texture2D = null

@export_category('Components')
@export var has_behavior:bool = false:
	set(value):
		has_behavior = value
		notify_property_list_changed()
@export var has_information:bool = true:
	set(value):
		has_information = value
		notify_property_list_changed()
@export var is_item:bool = false:
	set(value):
		is_item = value
		notify_property_list_changed()
@export var has_inventory:bool = true:
	set(value):
		has_inventory = value
		notify_property_list_changed()
@export var has_health:bool = false:
	set(value):
		has_health = value
		notify_property_list_changed()
@export var has_materia:bool = false:
	set(value):
		has_materia = value
		notify_property_list_changed()
@export var has_memory:bool = false:
	set(value):
		has_memory = value
		notify_property_list_changed()
@export var has_movement:bool = false:
	set(value):
		has_movement = value
		notify_property_list_changed()
@export var has_perception:bool = false:
	set(value):
		has_perception = value
		notify_property_list_changed()
@export var has_visual:bool = false:
	set(value):
		has_visual = value
		notify_property_list_changed()

# Behavior
var behavior_type:BehaviorComponent.Type = BehaviorComponent.Type.PREY
var behavior_tree:BehaviorTemplate = null

# Health
var health_specie:HealthComponent.Species = HealthComponent.Species.ANIMAL
var health_agility:int = 0
var health_mind:int = 1
var health_spirit:int = 1
var health_vitality:int = 1

# Information
var info_name:String = ""
var info_gender:String = "Female"

# Inventory
var inventory_capacity:int = 3

# Item
var item_type:ItemComponent.Type = ItemComponent.Type.ERROR
var item_quality:ItemComponent.Quality = ItemComponent.Quality.COMMON
var item_quantity:int = 1
var item_owner_uid:int = -1
var item_last_owner:int = -1

# Materia
var materia_essence:MateriaComponent.Essence = MateriaComponent.Essence.EARTH
var materia_composition:Array[MateriaComponent.Materia] = []

# Memory
var memory_

# Movement
var movement_type:MovementComponent.Type = MovementComponent.Type.GROUND
var movement_weight:MovementComponent.Weight = MovementComponent.Weight.NORMAL
var movement_point:Vector2 = DIR.NULL_POS
var movement_solid:bool = false
var movement_snap:bool = true

# Perception
var percep_attention_limit:int = 3
var percep_max_attempts:int = 10
var percep_vision_range:Dictionary = {
	'length': 14.0,
	'width': 6.0,
	'back_ratio': 0.1
	}
var percep_scan_pattern:PerceptionComponent.Pattern = PerceptionComponent.Pattern.RANDOM
var percep_sweep_dir:int = 1
var percep_angle:float = 0.0
var percep_scan_speed:float = 1.0
var percep_forward_ratio:float = 0.7
var percep_debug:bool = false

# Visual
var visual_sprite_frames:SpriteFrames

func _get_behav_type_as_long_string()->String:
	return ",".join(BehaviorComponent.Type.keys())
func _get_species_as_long_string()->String:
	return ",".join(HealthComponent.Species.keys())
func _get_essence_as_long_string()->String:
	return ",".join(MateriaComponent.Essence.keys())
func _get_item_type_as_long_string()->String:
	return ",".join(ItemComponent.Type.keys())
func _get_item_quality_as_long_string()->String:
	return ",".join(ItemComponent.Quality.keys())
func _get_materia_as_long_string() -> String:
	var keys := MateriaComponent.Materia.keys()
	var parts:Array[String] = []
	for i in keys.size():
		parts.append("%s:%d" % [keys[i], i])
	return ",".join(parts)
func _get_mov_type_as_long_string()->String:
	return ",".join(MovementComponent.Type.keys())
func _get_mov_weight_as_long_string()->String:
	return ",".join(MovementComponent.Weight.keys())
func _get_scan_pattern_as_long_string()->String:
	return ",".join(PerceptionComponent.Pattern.keys())
func _get_property_list() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	if has_behavior:
		list.push_back({
			"name": "behavior_type",
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_EDITOR,
			"hint":  PROPERTY_HINT_ENUM,
			"hint_string": _get_behav_type_as_long_string()
		})
		list.push_back({
			"name": "behavior_tree",
			"type": TYPE_OBJECT,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_EDITOR,
			"hint": PROPERTY_HINT_RESOURCE_TYPE,
			"hint_string": "BehaviorTemplate"
		})
	if has_health:
		list.push_back({
			"name": "health_specie",
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_EDITOR,
			"hint":  PROPERTY_HINT_ENUM,
			"hint_string": _get_species_as_long_string()
		})
		for key_attr:Dictionary in [
				{
				"name": "health_agility",
				"type": TYPE_INT,
				"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_EDITOR,
				"hint_string": "0,999,1"
				},
				{
				"name": "health_spirit",
				"type": TYPE_INT,
				"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_EDITOR,
				"hint_string": "0,999,1"
				},
				{
				"name": "health_mind",
				"type": TYPE_INT,
				"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_EDITOR,
				"hint_string": "0,999,1"
				},
				{
				"name": "health_vitality",
				"type": TYPE_INT,
				"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_EDITOR,
				"hint_string": "0,999,1"
				}
			]:
			list.append(key_attr)
	if has_information:
		list.push_back({
			"name": "info_name",
			"type": TYPE_STRING,
		})
		list.push_back({
			"name": "info_gender",
			"type": TYPE_STRING,
		})
	if has_inventory:
		list.push_back({
			"name": "inventory_capacity",
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_EDITOR
		})
	if has_materia:
		list.push_back({
			"name": "materia_essence",
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_EDITOR,
			"hint":  PROPERTY_HINT_ENUM,
			"hint_string": _get_essence_as_long_string()
		})
		list.push_back({
			"name": "materia_composition",
			"type": TYPE_ARRAY,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_EDITOR,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": "%d/%d:%s" % [TYPE_INT, PROPERTY_HINT_ENUM, _get_materia_as_long_string()]
		})
	if has_movement:
		list.push_back({
			"name": "movement_type",
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_EDITOR,
			"hint":  PROPERTY_HINT_ENUM,
			"hint_string": _get_mov_type_as_long_string()
		})
		list.push_back({
			"name": "movement_weight",
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_EDITOR,
			"hint":  PROPERTY_HINT_ENUM,
			"hint_string": _get_mov_weight_as_long_string()
		})
		list.push_back({
			"name": "movement_point",
			"type": TYPE_VECTOR2,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_EDITOR,
		})
		list.push_back({
			"name": "movement_solid",
			"type": TYPE_BOOL,
		})
		list.push_back({
			"name": "movement_snap",
			"type": TYPE_BOOL,
		})
	if has_perception:
		list.push_back({
			"name": "percep_attention_limit",
			"type": TYPE_INT,
		})
		list.push_back({
			"name": "percep_max_attempts",
			"type": TYPE_INT,
		})
		list.push_back({
			"name": "percep_vision_range",
			"type": TYPE_DICTIONARY,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_EDITOR,
			"hint": PROPERTY_HINT_DICTIONARY_TYPE,
			"hint_string": "String;float"
		})
		list.push_back({
			"name": "percep_scan_pattern",
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_EDITOR,
			"hint":  PROPERTY_HINT_ENUM,
			"hint_string": _get_scan_pattern_as_long_string()
		})
		list.push_back({
			"name": "percep_sweep_dir",
			"type": TYPE_INT,
		})
		list.push_back({
			"name": "percep_angle",
			"type": TYPE_FLOAT,
		})
		list.push_back({
			"name": "percep_scan_speed",
			"type": TYPE_FLOAT,
		})
		list.push_back({
			"name": "percep_forward_ratio",
			"type": TYPE_FLOAT,
		})
		list.push_back({
			"name": "percep_debug",
			"type": TYPE_BOOL,
		})
	if has_visual:
		list.push_back({
			"name": "visual_sprite_frames",
			"type": TYPE_OBJECT,
			"hint": PROPERTY_HINT_RESOURCE_TYPE,
			"hint_string": "SpriteFrames",
		})
	if is_item:
		list.push_back({
			"name": "item_type",
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_EDITOR,
			"hint":  PROPERTY_HINT_ENUM,
			"hint_string": _get_item_type_as_long_string()
		})
		list.push_back({
			"name": "item_quality",
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_EDITOR,
			"hint":  PROPERTY_HINT_ENUM,
			"hint_string": _get_item_quality_as_long_string()
		})
		list.push_back({
			"name": "item_quantity",
			"type": TYPE_INT,
		})
		list.push_back({
			"name": "item_owner_uid",
			"type": TYPE_INT,
		})
		list.push_back({
			"name": "item_last_owner",
			"type": TYPE_INT,
		})
	return list
