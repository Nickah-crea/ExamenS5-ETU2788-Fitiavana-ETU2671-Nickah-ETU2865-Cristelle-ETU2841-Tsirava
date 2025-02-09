extends Area2D

signal egg_clicked  # Signal émis quand on clique sur l'œuf

@onready var sprite = $Sprite2D  # Référence au sprite

func _ready():
	print("Oeuf prêt :", self)  # Vérification que l'œuf est bien chargé

func _input_event(_viewport, event, _shape_idx):  
	if event is InputEventMouseButton and event.pressed:
		print("Œuf cliqué ! Envoi du signal...")
		egg_clicked.emit(global_position)  # Émet le signal avec la position de l'œuf
		visible = false  # Cache l'œuf
