extends Area2D

signal bread_clicked(global_position)  # Signal émis avec la position du pain

@onready var sprite = $Sprite2D  # Référence au sprite
var click_count = 0  # Compteur de clics
var last_click_time = 0.0  # Temps du dernier clic
const DOUBLE_CLICK_TIME = 0.3  # Temps maximal entre deux clics pour un double clic

func _ready():
	print("Pain prêt :", self)  # Vérification que le pain est bien chargé

func _input_event(_viewport, event, _shape_idx):  
	if event is InputEventMouseButton and event.pressed:
		var current_time = Time.get_ticks_msec() / 1000.0  # Temps en secondes
		if current_time - last_click_time < DOUBLE_CLICK_TIME:
			# Double clic détecté
			print("Double clic sur le pain !")
			click_count = 0  # Réinitialisation
		else:
			# Clic simple
			print("Pain cliqué ! Envoi du signal...")
			bread_clicked.emit(global_position)
			visible = false  # Cache le pain
		
		last_click_time = current_time
