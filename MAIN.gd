extends Node

@export var animations:Resource = null
@export var archetypes:Resource = null
@export var cam_manager:CAMERA_MANAGER = null

@export var WIDTH:int = 24
@export var HEIGHT:int = 24
@export var SCALE:int = 16

const AType = EntityStore.Archetypes

func _ready()->void:
	DIR.start(self, 256, WIDTH, HEIGHT, SCALE)
	
	DIR.system_start(AnimationSystem)
	DIR.system_start(BehaviorSystem)
	DIR.system_start(HealthSystem)
	DIR.system_start(InformationSystem)
	DIR.system_start(ItemSystem)
	DIR.system_start(MovementSystem)
	DIR.system_start(RenderSystem)
	DIR.system_start(TerrainSystem)
	
	DIR.get_system(TerrainSystem).start()
	
	for n in 5*5:
		EntityConstructor.spawn_type(AType.DUCK)
	for n in 5*5:
		EntityConstructor.spawn_type(AType.RED_BUSH)
	for n in 1:
		EntityConstructor.spawn_type(AType.PINETREE)
	for n in 3:
		EntityConstructor.spawn_type(AType.G_SLIME)
	for n in 6:
		EntityConstructor.spawn_type(AType.R_BERRY)
	for n in 6:
		EntityConstructor.spawn_type(AType.B_BERRY)
	var iphrit_id:int = EntityConstructor.spawn_type(AType.IPHRIT)
	DIR.get_system(InformationSystem).instance()
	
	cam_manager.start(DIR.get_ent_position(iphrit_id))
	cam_manager.follow_uid = iphrit_id
	DIR.DEBUG.watch_hitbox(iphrit_id)
	
	#for point:Vector2i in DIR._map:
		#print(point, ": ", DIR._map[point])
func _process(delta:float)->void:
	for system:BaseSystem in DIR._systems.values():
		system.process()
	DIR.DEBUG.process()
	DIR.delta = delta
	cam_manager.process(delta)
