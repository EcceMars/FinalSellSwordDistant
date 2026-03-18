@icon("res://assets/icons/store_base.png")
class_name DataStore
extends Resource

@export var data_name:String = ""
@export_custom(PROPERTY_HINT_DICTIONARY_TYPE, "String;Resource") var data_arr:Dictionary[String, Resource] = {}
