extends CharacterBody2D

const MOTION_SPEED = 160 # Pixels/second.
var last_direction = Vector2(1, 0)
var carrying_egg = false  # Indique si l'œuf est porté
var held_egg = null  # Référence à l'œuf que le personnage porte
var carrying_bread = false  # Indique si le pain est porté
var held_bread = null  # Référence au pain que le personnage porte

# Ajoutez une variable pour vérifier si l'œuf a déjà été placé
var egg_placed = false
var bread_placed = false  # Vérifie si le pain a été placé
var click_count = 0  # Compteur pour le nombre de clics

@onready var poele = get_node("/root/Game/Food/Poel2")  # Référence à la poêle
@onready var plat = get_node("/root/Game/Food/02Dish2")  # Référence au plat
@onready var sprite = $AnimatedSprite2D  # Sprite du personnage

var anim_directions = {
	"idle": [["front_idle", false]],
	"walk": [["side_right_walk", false], ["front_walk", false], ["side_left_walk", false], ["back_walk", false]],
}

func _ready():
	var egg = get_node_or_null("/root/Game/Oeuf")  # Remplacez par le bon chemin
	if egg:
		egg.egg_clicked.connect(on_egg_clicked)
	
	var bread = get_node_or_null("/root/Game/Bread")  # Remplacez par le bon chemin
	if bread:
		bread.bread_clicked.connect(on_bread_clicked)

	# Crée un nœud pour l'œuf que le personnage tiendra dans sa main
	held_egg = Sprite2D.new()
	held_egg.texture = preload("res://assets/sprites/Food/ingredient/39_friedegg_dish.png")  # Remplace par le bon chemin
	held_egg.visible = false  # L'œuf est invisible au début
	held_egg.scale = Vector2(0.5, 0.5)  # Réduit la taille de l'œuf
	sprite.add_child(held_egg)  # Ajoute l'œuf comme enfant du sprite pour qu'il suive le personnage
	
	# Crée un nœud pour le pain que le personnage tiendra dans sa main
	held_bread = Sprite2D.new()
	held_bread.texture = preload("res://assets/sprites/Food/ingredient/07_bread.png")  # Remplace par le bon chemin
	held_bread.visible = false  # Le pain est invisible au début
	held_bread.scale = Vector2(0.5, 0.5)  # Réduit la taille du pain
	sprite.add_child(held_bread)  # Ajoute le pain comme enfant du sprite pour qu'il suive le personnage

func on_egg_clicked(_arg = null):  
	print("Œuf ramassé !")
	carrying_egg = true
	held_egg.visible = true
	update_held_egg_position()  # Met à jour la position pour le mettre dans la main du joueur
	
	await get_tree().create_timer(5000).timeout  
	print("Œuf placé dans la poêle.")

	# Ajouter un nouvel œuf dans la poêle sans cacher celui de la main
	var oeuf_poele = Sprite2D.new()
	oeuf_poele.texture = held_egg.texture
	oeuf_poele.position = poele.position  # Place l'œuf dans la poêle
	poele.add_child(oeuf_poele)

	# Faire disparaître l'œuf de la main après un délai supplémentaire
	await get_tree().create_timer(1).timeout
	held_egg.visible = false
	carrying_egg = false

func on_bread_clicked(_arg = null):
	print("Pain ramassé !")
	carrying_bread = true
	held_bread.visible = true
	update_held_bread_position()  # Met à jour la position du pain
	
	# Ajoutez une action de placement du pain après un délai
	await get_tree().create_timer(5000).timeout
	print("Pain placé dans le plat.")

	# Ajouter un pain dans le plat sans cacher celui de la main
	var bread_plat = Sprite2D.new()
	bread_plat.texture = held_bread.texture
	bread_plat.position = plat.position  # Place le pain dans le plat
	plat.add_child(bread_plat)

	# Faire disparaître le pain de la main après un délai supplémentaire
	await get_tree().create_timer(1).timeout
	held_bread.visible = false
	carrying_bread = false

func update_held_egg_position():
	var offset = Vector2(8, 10)  # Décale légèrement l'œuf
	if last_direction.x < 0:  # Gauche
		offset.x = -8
	elif last_direction.y < 0:  # Haut
		offset = Vector2(0, -10)
	elif last_direction.y > 0:  # Bas
		offset = Vector2(0, 12)

	# Toujours mettre à jour la position de l'œuf en fonction de la position du sprite du joueur
	held_egg.position = sprite.position + offset  # Assurez-vous que l'œuf suit la position du sprite du joueur

func update_held_bread_position():
	var offset = Vector2(8, 10)  # Décale légèrement le pain
	if last_direction.x < 0:  # Gauche
		offset.x = -8
	elif last_direction.y < 0:  # Haut
		offset = Vector2(0, -10)
	elif last_direction.y > 0:  # Bas
		offset = Vector2(0, 12)

	# Toujours mettre à jour la position du pain en fonction de la position du sprite du joueur
	held_bread.position = sprite.position + offset  # Assurez-vous que le pain suit la position du sprite du joueur

func _physics_process(_delta):
	var motion = Vector2()
	motion.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	motion.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	motion = motion.normalized() * MOTION_SPEED

	set_velocity(motion)
	move_and_slide()

	if motion.length() > 0:
		last_direction = motion
		update_animation("walk")
	else:
		update_animation("idle")

	if carrying_egg:
		update_held_egg_position()
	if carrying_bread:
		update_held_bread_position()

# Fonction de détection de la collision avec la poêle ou le plat pour l'œuf
func _on_area_entered(area: Area2D) -> void:
	if carrying_egg:
		if area == poele and not egg_placed:  # Si la collision est avec la poêle et que l'œuf n'a pas encore été placé
			print("Œuf placé dans la poêle.")
			var oeuf_poele = Sprite2D.new()
			oeuf_poele.texture = held_egg.texture
			oeuf_poele.position = poele.position  # Place l'œuf dans la poêle
			poele.add_child(oeuf_poele)
			
			# Faire disparaître l'œuf de la main
			held_egg.visible = false
			carrying_egg = false
			egg_placed = true  # L'œuf est maintenant placé, on marque qu'il est resté là

# Ajoutez une fonction pour gérer le clic double pour placer l'œuf où vous cliquez
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if carrying_egg:
			click_count += 1

			if click_count == 2:  # Si c'est le deuxième clic
				var click_position = event.position
				print("Placer l'œuf à la position:", click_position)

				# Placez l'œuf à la position du clic
				held_egg.position = click_position
				held_egg.visible = true  # Affiche l'œuf à la nouvelle position
				carrying_egg = false
				click_count = 0  # Réinitialisez le compteur de clics
		elif carrying_bread:
			click_count += 1

			if click_count == 2:  # Si c'est le deuxième clic
				var click_position = event.position
				print("Placer le pain à la position:", click_position)

				# Placez le pain à la position du clic
				held_bread.position = click_position
				held_bread.visible = true  # Affiche le pain à la nouvelle position
				carrying_bread = false
				click_count = 0  # Réinitialisez le compteur de clics

# Fonction d'animation du personnage
func update_animation(anim_set):
	var angle : float
	var slice_dir : int

	if last_direction.length() == 0:
		slice_dir = 0  # Animation idle (face)
	else:
		angle = rad_to_deg(last_direction.angle())
		slice_dir = int(floor((angle + 22.5) / 90)) % anim_directions[anim_set].size()

	if slice_dir == 0:
		anim_set = "idle"
	elif slice_dir == 1:
		anim_set = "walk_right"
	elif slice_dir == 2:
		anim_set = "walk_back"
	elif slice_dir == 3:
		anim_set = "walk_left"
