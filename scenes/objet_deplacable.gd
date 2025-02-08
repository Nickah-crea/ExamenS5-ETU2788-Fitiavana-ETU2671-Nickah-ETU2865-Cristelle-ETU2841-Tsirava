extends Node2D

var dragging = false  # Indique si l'objet est en train d'être déplacé
var offset = Vector2()  # Distance entre la souris et l'objet

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Vérifie si la souris clique sur l'objet
				var mouse_pos = get_global_mouse_position()
				if $CollisionShape2D.shape and $CollisionShape2D.get_global_rect().has_point(mouse_pos):
					dragging = true
					offset = global_position - mouse_pos
			else:
				dragging = false

func _process(delta):
	if dragging:
		# Déplace l'objet en suivant la position de la souris
		global_position = get_global_mouse_position() + offset
