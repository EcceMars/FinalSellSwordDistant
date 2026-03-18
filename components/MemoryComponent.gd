class_name MemoryComponent
extends BaseComponent

enum Type {
	CURIOSITY, 		## Not classified
	
	ENEMY,			## Threatning entity
	FOOD,			## Item seem as food
	HAZARD,			## Area classified as dangerous
	MATE,			## Entity seem as friendly
	PREY,			## Entity seem as food
	RESOURCE,		## Position of a certain resource
	WATER			## Position of a water source
	}

var intelligence:float = 1.0
var memories:Array[Memory] = []

func _init(id:int)->void:
	super(id)
	var health:HealthComponent = get_health()
	if health:
		intelligence = health.mind.value
## Classifies a [PerceptionComponent.RayResult]
func classify(ray:PerceptionComponent.RayResult)->Type:
	if get_item(ray.hit_entity):
		return Type.FOOD
	if ray.raw_data == 'water':
		return Type.WATER
	
	var alt_health:HealthComponent = get_health(ray.hit_entity)
	if not alt_health: return Type.CURIOSITY
	
	const S = HealthComponent.Species
	if alt_health.specie in [S.PLANT, S.TREE]: return Type.FOOD
	
	var health:HealthComponent = get_health()
	
	const B = BehaviorComponent.Type
	var behav:BehaviorComponent = get_behavior()
	
	const M = MateriaComponent.Materia
	var alt_mat:MateriaComponent = alt_health.get_materia()
	
	if behav:
		if alt_health.specie == behav.blackboard.predator_species:
			return Type.ENEMY
		if behav.type == B.PREY:
			if alt_health.specie == S.ITEM or alt_health.specie == S.PLANT:
				return Type.FOOD
		elif behav.type == B.PREDATOR:
			# There is an animal entity
			if alt_health.specie == behav.blackboard.seek_which:
				return Type.PREY
			# There is meat or bones on the floor
			if alt_health.specie == S.ITEM and alt_mat and M.ANIMAL in alt_mat.materials:
				return Type.FOOD
		if alt_health.specie == health.specie if health else false:
			return Type.MATE
	return Type.CURIOSITY
func update_memory(who:int, type:Type, position:Vector2, confidence:float = 1.0)->Memory:
	var generation:int = DIR._generations.get(who, 0)
	for memory:Memory in memories:
		if who < 0:
			if memory.type == type and memory.position.distance_to(position) > DIR.SCALE * 2:
				memory.position = position
				memory.last_seen = Time.get_unix_time_from_system()
				memory.force = confidence
				return memory
			continue
		if memory.who == who:
			if memory.generation != generation:
				memory.type = type
				memory.generation = generation
				memory.force = confidence
			memory.position = position
			memory.last_seen = Time.get_unix_time_from_system()
			memory.force = confidence
			return memory
	var new_entry:Memory = Memory.new(who, type, position, confidence)
	new_entry.generation = generation
	memories.append(new_entry)
	return memories.back()
func get_recent_memories(type:Type, force:float = 0.5)->Array[Memory]:
	var result:Array[Memory] = []
	var now:float = Time.get_unix_time_from_system()
	for memory:Memory in memories:
		if memory.type != type: continue
		
		var decay:float = 0.1 / intelligence
		var current_force:float = memory.force * exp(-decay * (now - memory.last_seen))
		if current_force >= force:
			result.append(memory)
	return result
func remember_closer(mem_type:Type, filter_data:Dictionary = {})->Memory:
	var best_candidate:Memory = null
	var closest_distance:float = INF
	for memory:Memory in memories:
		if memory.type != mem_type: continue
		if not memory.is_valid(): continue
		
		if not filter_data.is_empty():
			var match_filter = true
			for key in filter_data:
				if memory.meta.get(key) != filter_data[key]:
					match_filter = false
					break
			if not match_filter:
				continue
		var distance:float = get_movement().position.distance_to(memory.position)
		if distance > closest_distance: continue
		
		var time_seen:float = Time.get_unix_time_from_system() - memory.last_seen
		var decay:float = 0.1 / intelligence
		var current_force:float = memory.force * exp(-decay * time_seen)
		
		if current_force > 0.3:
			closest_distance = distance
			best_candidate = memory
	return best_candidate
class Memory:
	var who:int = -1
	var generation:int = 0
	var position:Vector2 = DIR.NULL_POS
	var type:Type = Type.CURIOSITY
	var force:float = 1.0
	var begin:float = 0.0
	var last_seen:float = begin
	var meta:Dictionary = {}
	
	func _init(_uid:int, _type:Type, pos:Vector2, confidence:float = force)->void:
		who = _uid
		position = pos
		type = _type
		force = confidence
		begin = Time.get_unix_time_from_system()
		last_seen = begin
	func is_valid()->bool:
		if who < 0 and type in [Type.HAZARD, Type.WATER]: return true
		return DIR.is_valid_entity(who) and DIR._generations.get(who, 0) == generation
	func _to_string()->String:
		var message:String = get_script().get_global_name()
		if who < 0:
			message += " -> Feature of type %s found at %v." % [Type.keys()[type], MovementSystem.world_to_grid(position)]
		else:
			message += " -> %d is remembered here %v, and is thought as %s." % [who, MovementSystem.world_to_grid(position), Type.keys()[type]]
		
		return message
