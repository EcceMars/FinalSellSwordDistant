class_name InformationComponent
extends BaseComponent

var name:String = "":
	get:
		if not identity: return ""
		return identity.name
var gender:String = "":
	get:
		if not identity: return ""
		return identity.gender
var action:String = "":
	get:
		if not identity: return ""
		return identity.action

var identity:Identity = null

func _init(id:int, _name:String, _gender:String = "female") -> void:
	super(id)
	identity = Identity.new(_name, _gender)
func destroy()->void:
	DIR.get_system(InformationSystem).destroy(uid)
class Identity:
	var name:String = "unnamed"
	var gender:String = "female"
	var action:String = ""
	func _init(_name:String, _gender:String = "female")->void:
		name = _name
		gender = _gender
