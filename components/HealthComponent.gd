## This is a general RPG-esque component.
class_name HealthComponent
extends BaseComponent

## General species classification
enum Species {
	VOID,			## ERROR
	
	ANIMAL,			## Most neutral animals
	BEAST,			## Predator types of creatures (TODO: should enlarge to create competing beasts (different types of monsters))
	GOD,			## Debugging entity
	HUMAN,
	ITEM,			## Usually unmoving object
	PLANT,			## Smaller plants, usually food
	STONE,			## Stone resource
	TREE				## Larger plants, for wood resource
	}
## All static-coded (these and the [Vitals]) as behaviors and such will be heavily dependend on this.
enum Attributes {
	AGILITY,			## Base for general combat and movement dexterity
	MIND,			## Base for perception and general intelligence capabilities
	SPIRIT,			## Base for general mana usage (usage of Magick and endurance)
	VITALITY			## Base for strenght and health statistics
	}
enum Vitals {
	BLOOD,			## Hitpoints
	ENERGY,			## Action points (to use normal actions)
	HUNGER,			## If the entity can starve
	MANA,			## Magick points (to use magical actions)
	THIRST			## If the entity needs thirsty
	}
var specie:Species = Species.ANIMAL
var attributes:Dictionary[Attributes, Attribute] = {}
var vitals:Dictionary[Vitals, Vital] = {}

var level:int = 1
var experience:float = 0.0

var agility:Attribute:
	get:
		if not attributes.get(Attributes.AGILITY): return Attribute.new(Attributes.AGILITY, 0)
		return attributes[Attributes.AGILITY]
var mind:Attribute:
	get:
		if not attributes.get(Attributes.MIND): return Attribute.new(Attributes.MIND, 0)
		return attributes[Attributes.MIND]
var spirit:Attribute:
	get:
		if not attributes.get(Attributes.SPIRIT): return Attribute.new(Attributes.SPIRIT, 0)
		return attributes[Attributes.SPIRIT]
var vitality:Attribute:
	get:
		if not attributes.get(Attributes.VITALITY): return Attribute.new(Attributes.VITALITY, 0)
		return attributes[Attributes.VITALITY]

var blood:Vital:
	get:
		if not vitals.get(Vitals.BLOOD): return Vital.new(Vitals.BLOOD, 0)
		return vitals[Vitals.BLOOD]
var mana:Vital:
	get:
		if not vitals.get(Vitals.MANA): return Vital.new(Vitals.MANA, 0)
		return vitals[Vitals.MANA]

var hunger:Vital:
	get:
		if not vitals.get(Vitals.HUNGER): return Vital.new(Vitals.HUNGER, 0)
		return vitals[Vitals.HUNGER]
var thirst:Vital:
	get:
		if not vitals.get(Vitals.THIRST): return Vital.new(Vitals.THIRST, 0)
		return vitals[Vitals.THIRST]
var energy:Vital:
	get:
		if not vitals.get(Vitals.ENERGY): return Vital.new(Vitals.ENERGY, 0)
		return vitals[Vitals.ENERGY]

func _init(id:int, stat_data:Dictionary)->void:
	super(id)
	if stat_data.has('health_specie'): specie = stat_data.health_specie
	
	# Initialize attributes from stat_data if provided
	if stat_data.has('health_attributes'):
		for attr:Attributes in stat_data.health_attributes:
			var attr_value:int = stat_data.health_attributes[attr]
			add_attribute(attr, attr_value)
	assert_vitals()
func add_attribute(attr_type:Attributes, value: int = 0)->void:
	var attr:Attribute = Attribute.new(attr_type, value)
	attributes[attr_type] = attr
func assert_vitals()->void:
	# The float magic number here should be referent to the species stat curve times the level
	vitals[Vitals.BLOOD] = Vital.new(Vitals.BLOOD, 10.0 * get_attribute(Attributes.VITALITY).value * level)
	vitals[Vitals.ENERGY] = Vital.new(Vitals.ENERGY, 10.0 * get_attribute(Attributes.VITALITY).value * level)
	vitals[Vitals.HUNGER] = Vital.new(Vitals.HUNGER, 10.0 * get_attribute(Attributes.VITALITY).value * level)
	vitals[Vitals.MANA] = Vital.new(Vitals.MANA, 10.0 * get_attribute(Attributes.SPIRIT).value * level)
	vitals[Vitals.THIRST] = Vital.new(Vitals.THIRST, 10.0 * get_attribute(Attributes.VITALITY).value * level)
	
func get_attribute(att:Attributes)->Attribute:
	return attributes.get(att)
func _to_string()->String:
	var message:String = super()
	for attribute:Attribute in attributes.values():
		message += "\n\t" + str(attribute)
	message += "\n"
	for vital:Vital in vitals.values():
		message += "\n\t" + str(vital)
	return message
## Base values that will be used to scale [Vital] statistics and interact with specific functions (combat etc.).
class Attribute:
	var type:Attributes = Attributes.AGILITY
	var value:int = 0		# This should be a factor to increase a vital, for example, a high vitallity should increase the maximum of the blood Vital.
	func _init(_type:Attributes, _value:int)->void:
		type = _type
		value = _value
	func _to_string()->String:
		return Attributes.keys()[type] + ": " + str(value)
## Basic need value. All can potentially kill the entity, while blood is the main agent on this.
class Vital:
	var type:Vitals = Vitals.BLOOD
	var limit:float = 100.0
	var value:float = limit
	func _init(_type:Vitals, _limit:float)->void:
		type = _type
		limit = _limit
		value = limit
	func is_depleted()->bool:
		return value <= 0.0
	func is_under(threshold:float)->bool:
		return value < threshold
	func ratio()->float:
		return value / limit
	func modify(amount:float)->bool:
		if limit == 0: return false			# If this is an unnused vital (for entities that don't have such vital)
		value = clampf(value + amount, 0.0, limit)
		return is_depleted()
	func _to_string()->String:
		return Vitals.keys()[type] + ": %.2f/%.2f" % [value, limit]
