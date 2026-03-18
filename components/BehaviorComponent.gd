## Manages entity's behavior
class_name BehaviorComponent
extends BaseComponent

const Status = Behavior.Status
## General behavior type.
enum Type {
	CHAMPION,			## For now, controlled by the player (this will change as NPCs could be champions as well)
	CHILD,				## Will wander, rest and idle about
	GUARD,				## Attempts to protect the same [enum HealthComponent.Species], with patrolling routines
	HUNTER,				## Similar to both [enum Type.PREDATOR] and [enum Type.WORKER], attempts to hunt and bring food to a pack_center (villages, dens etc.)
	TROLL,				## Adversary type of entity. May start fires or steal food and resources (trickster)
	PREDATOR	,		## Carnivore, hunts entities that have not the same [enum HealthComponent.Species]
	PREY,				## Herbivore, usually will flee from other entities (that have not the same [enum HealthComponent.Species])
	FOLLOWER,			## Debug behavior. Use it to have an entity follow another without needing either the [PerceptionComponent] or the [MemoryComponent]
	WORKER				## Attempts to find food and contextually needed resources and leave at a pack_center
	}
var type:Type = Type.PREY
var blackboard:Blackboard = null
var root_behavior:Behavior = null
var status:Status = Status.DONE

func _init(id:int)->void:
	super(id)
	blackboard = Blackboard.new()
func _create_condition(cond_name:String)->BehaviorCondition:
	return BehaviorCondition.new(Callable(self, cond_name), BehaviorSequence.new())
func has_target(behav_comp:BehaviorComponent = null)->bool:
	if not behav_comp:
		return not blackboard.target_entity < 0
	return not behav_comp.blackboard.target_entity < 0
func update()->void:
	if blackboard.wait_for > 0:
		blackboard.wait_for -= DIR.delta
		return
	if root_behavior:
		status = root_behavior.tick(uid, self)
		blackboard.last_status = status
		
		if blackboard.animation:
			change_animation()
func change_animation()->void:
	if blackboard.wait_animation:
		DIR.get_system(AnimationSystem).play_animation_after(uid, blackboard.animation)
		blackboard.wait_animation = false
		return
	DIR.get_system(AnimationSystem).play_animation(uid, blackboard.animation)
func is_threatened()->bool:
	return not blackboard.threat < 0
func is_hungry()->bool:
	var health:HealthComponent = get_health()
	if not health: return false
	return health.vitals[HealthComponent.Vitals.HUNGER].ratio() < blackboard.needs.hunger_threshold
func is_thirsty()->bool:
	var health:HealthComponent = get_health()
	if not health: return false
	return health.vitals[HealthComponent.Vitals.THIRST].ratio() < blackboard.needs.thirst_threshold
func is_tired()->bool:
	var health:HealthComponent = get_health()
	if not health: return false
	return health.vitals[HealthComponent.Vitals.ENERGY].ratio() < blackboard.needs.tiredness_threshold
func _to_string()->String:
	var message:String = super() + "\n"
	message += str(root_behavior) + "\n\n"
	message += str(blackboard)
	return message
## Blackboard object to help organize and keep data static.
class Blackboard:
	## Key name for the next animation
	var animation:String = 'idle'
	## Entity classified as an enemy (will attempt combat)
	var enemy:int = -1
	## Usually same [enum HealthComponent.Species]
	var friend:int = -1
	## Area an entity finds dangerous (enemy hideouts, natural dangerous places)
	var hazard:Rect2 = DIR.NULL_AREA				# For small areas, maybe an array of Vector2i could suffice
	## For sequences and routines
	var last_status:Status = Status.ABORTED
	## What type of [enum MateriaComponent.Materia] the entity is seeking
	var materia_wanted:Array[MateriaComponent.Materia] = [MateriaComponent.Materia.NONE]
	## Actual memory entry
	var mem_entry:MemoryComponent.Memory = null
	## Type of memory to recall or search for
	var mem_type:MemoryComponent.Type = MemoryComponent.Type.CURIOSITY
	var needs:Needs = null
	## [enum HealthComponent.Species] naturally dangerous to this entity
	var predator_species:HealthComponent.Species = HealthComponent.Species.BEAST # TODO: this will probably be turned into an array
	## [enum HealthComponent.Species] the entity is searching for
	var seek_which:HealthComponent.Species = HealthComponent.Species.ANIMAL # TODO: same as above
	## unique id (uid) of the entity this entity is searching for
	var target_entity:int = -1
	## Entity identified as dangerous contextually (will attempt to flee, or seek reinforcement)
	var threat:int = -1
	## An animation change must occur after the current one is done (e.g. walk -> idle)
	var wait_animation:bool = false
	## Wait timer
	var wait_for:float = 0.0
	## Water source
	var water_location:Vector2 = DIR.NULL_POS
	## New position target
	var where_to:Vector2 = DIR.NULL_POS
	
	func _init()->void:
		needs = Needs.new()
	func _to_string()->String:
		var message:String = "Blackboard:\n\t"
		var data:Dictionary = {
			'animation': animation,
			'enemy': enemy,
			'friend': friend,
			'hazard': hazard,
			'last_status': Status.keys().get(last_status),
			'materia_wanted': materia_wanted,
			'needs': needs,
			'predator_species': HealthComponent.Species.keys().get(predator_species),
			'seek_which': HealthComponent.Species.keys().get(seek_which),
			'target_entity': target_entity,
			'threat': threat,
			'wait_for': wait_for,
			'water_location': water_location,
			'where_to': where_to
		}
		
		for key in data:
			message += key + ": " + str(data[key]) + "\n\t"
		return message
class Needs:
	var hunger_threshold:float = 0.4
	var thirst_threshold:float = 0.5
	var fear_threshold:float = 0.6
	var tiredness_threshold:float = 0.3
	func _to_string()->String:
		return "Thresholds: h[%.2f] | t[%.2f] | f[%.2f] | e[%.2f]" % [hunger_threshold, thirst_threshold, fear_threshold, tiredness_threshold]
