@tool
class_name EntityStore
extends DataStore

enum Archetypes {
	B_BERRY,
	DUCK,
	G_SLIME,
	IPHRIT,
	R_BERRY,
	RED_BUSH,
	PINETREE
	}
static var _REGISTERED:Dictionary[Archetypes, String] = {
	Archetypes.B_BERRY:			'BlueBerry',
	Archetypes.DUCK:			'Duck',
	Archetypes.G_SLIME:			'GreenSlime',
	Archetypes.IPHRIT:			'Iphrit',
	Archetypes.R_BERRY:			'RedBerry',
	Archetypes.RED_BUSH:		'RedBerryBush',
	Archetypes.PINETREE:		'PineTree'
	}
func get_and_load(archetype:Archetypes)->EntityTemplate:
	return data_arr[_REGISTERED[archetype]]
