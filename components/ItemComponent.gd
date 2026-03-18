class_name ItemComponent
extends BaseComponent

enum Type {
	ERROR,
	
	CONSUMABLE,
	RESOURCE
	}
enum Quality {
	USELESS = 0,
	COMMON = 1,
	STRONG = 2,
	NOBLE = 3,
	UNIQUE = 4,
	LEGENDARY = 5
	}
	
var template:String = ""
	
var type:Type = Type.ERROR
var quality:Quality = Quality.COMMON
var quantity:int = 1
var owner_uid:int = -1
var last_owner:int = -1

# A flag for not bundling together items may be useful if multiplayer ever got implemented
## Used for bundling items either at the inventory or as drop items.
func equals(other:ItemComponent)->bool:
	if type != other.type or quality != other.quality: return false	# If type and quality are different, they are different
	var materia:MateriaComponent = get_materia()
	var other_mat:MateriaComponent = get_materia(other.uid)
	if not materia and not other_mat: return true					# If both are devoid of materials, they are equal
	if not materia or not other_mat: return false					# If just one doesn't, they can't be equal
	return materia.equals(other_mat)									# Final check for composition
