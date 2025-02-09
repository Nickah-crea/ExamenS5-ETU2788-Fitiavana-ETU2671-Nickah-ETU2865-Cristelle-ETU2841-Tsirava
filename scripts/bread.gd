extends Area2D

signal bread_clicked  # Signal émis quand on clique sur le pain

@onready var sprite = $Sprite2D  # Référence au sprite
var click_count = 0  # Compteur de clics pour le double clic

func _ready():
	print("Pain prêt :", self)  # Vérification que le pain est bien chargé

func _input_event(_viewport, event, _shape_idx):  
	if event is InputEventMouseButton and event.pressed:
		click_count += 1  # Incrémente le nombre de clics

		# Clic simple pour émettre le signal
		if click_count == 1:
			print("Pain cliqué ! Envoi du signal...")
			bread_clicked.emit(global_position)  # Émet le signal avec la position du pain
			visible = false  # Cache le pain

		# Double clic pour action spécifique
		if click_count == 2:
			print("Double clic sur le pain !")
			click_count = 0  # Réinitialise le compte
