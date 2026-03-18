class_name HealthSystem
extends BaseSystem

const Species = HealthComponent.Species
const Vitals = HealthComponent.Vitals

func process()->void:
	for health:HealthComponent in DIR.request_all_components_of(HealthComponent):
		if health.specie in [Species.GOD, Species.ITEM, Species.PLANT, Species.STONE, Species.TREE]: continue
		
		health.hunger.modify(-0.1 * DIR.delta)
		health.thirst.modify(-0.5 * DIR.delta)
		health.energy.modify(-0.1 * DIR.delta)
		
		if health.hunger.is_depleted():
			health.blood.modify(-0.5 * DIR.delta)
		if health.hunger.is_depleted():
			health.blood.modify(-1.0 * DIR.delta)
		
		if health.blood.is_depleted():
			DIR.destroy_entity(health.uid)
