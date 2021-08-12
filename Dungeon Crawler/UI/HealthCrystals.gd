extends Control

const CRYSTAL_VALUE = 16

var max_crystals = 1 setget set_max_crystals
var crystals = 1 setget set_crystals

onready var emptyCrystal = $EmptyHealthCrystal
onready var fullCrystal = $FullHealthCrystal

func _ready():
	self.max_crystals = PlayerStats.max_health
	self.crystals = PlayerStats.health
	PlayerStats.connect("max_health_changed", self, "set_max_crystals")
	PlayerStats.connect("heath_changed", self, "set_crystals")

func set_max_crystals(value):
	max_crystals = max(1, value)
	self.crystals = max_crystals
	emptyCrystal.rect_size.x = CRYSTAL_VALUE * max_crystals

func set_crystals(value):
	crystals = clamp(value, 0, max_crystals)
	fullCrystal.rect_size.x = CRYSTAL_VALUE * crystals
