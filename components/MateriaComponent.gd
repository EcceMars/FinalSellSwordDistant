class_name MateriaComponent
extends BaseComponent

## Magick alignment
enum Essence {
	VOID,
	DARK,
	LIGHT,
	
	AIR,
	EARTH,
	FIRE,
	WATER
	}
enum Materia {
	NONE,			## Fallback
	
	ANIMAL,			## Meat, bones etc. are marked as animal
	ENERGY,			## All types of energy (natural or magical)
	FRUIT,			## Rarelly non-edible (in the case of herbivores)
	HERB,			## Smallest plants, usually food
	METAL,			## Metal resource
	PLANT,			## Small plants, usually source of food
	POISON,			## Toxic component
	STONE,			## Stone resource
	WOOD				## Large plants, usually resouce, are marked as wood
	}
var essence:Essence = Essence.EARTH
var materials:Array[Materia] = [Materia.NONE]

func _init(id:int, alignment:Essence = essence, composition:Array[Materia] = materials)->void:
	super(id)
	essence = alignment
	materials = composition
func equals(other:MateriaComponent)->bool:
	return (
		other.essence == essence and
		other.materials == materials
		)
func _to_string()->String:
	var message:String = super()
	message += "[%s] -> [ " % Essence.keys()[essence]
	for material:Materia in materials:
		message += Materia.keys()[material] + " "
	message += "]"
	return message
class Effect:
	var vital_change:Dictionary[HealthComponent.Vitals, float] = {}
	func _init(changes:Dictionary[HealthComponent.Vitals, float])->void:
		vital_change = changes
