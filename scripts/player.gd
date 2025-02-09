extends CharacterBody2D

const MOTION_SPEED = 160 # Pixels/second.
var last_direction = Vector2(1, 0)

var target_position = null  # Position de l'œuf quand cliqué
var carrying_egg = false  # Indique si l'œuf est porté
var held_egg = null  # Référence à l'œuf que le personnage porte

var anim_directions = {
	"idle": [["front_idle", false]],
	"walk": [["side_right_walk", false], ["front_walk", false], ["side_left_walk", false], ["back_walk", false]],
}

func _ready():
	# Connecte le signal de l'œuf
	var egg = get_node_or_null("/root/Oeuf")
	if egg:
		egg.egg_clicked.connect(on_egg_clicked)

	# Crée un nœud pour l'œuf que le personnage tiendra
	held_egg = Sprite2D.new()
	held_egg.texture = preload("res://assets/sprites/Food/ingredient/38_friedegg.png")  # Remplace par le chemin de ton œuf
	held_egg.visible = false  # L'œuf est invisible au début
	add_child(held_egg)

func on_egg_clicked(egg_pos):
	# Définit la cible du déplacement
	target_position = egg_pos
	print("Œuf cliqué à la position: ", target_position)

func _physics_process(_delta):
	var motion = Vector2()

	# Si le personnage doit aller récupérer l'œuf
	if target_position and not carrying_egg:
		motion = (target_position - global_position).normalized() * MOTION_SPEED
		
		# Vérifie s'il est arrivé à l'œuf
		if global_position.distance_to(target_position) < 10:
			carry_egg()
	
	else:  # Déplacement normal
		motion.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		motion.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		motion = motion.normalized() * MOTION_SPEED

	# Mise à jour du mouvement
	set_velocity(motion)
	move_and_slide()

	# Mise à jour de l'animation
	if motion.length() > 0:
		last_direction = motion
		update_animation("walk")
	else:
		update_animation("idle")

	# L'œuf n'est visible que si le personnage le porte
	if carrying_egg:
		held_egg.position = $AnimatedSprite2D.position + Vector2(20, -20)  # Ajuste la position
		held_egg.visible = true  # Affiche l'œuf uniquement s'il est porté
	else:
		held_egg.visible = false  # Cache l'œuf s'il n'est pas porté

func carry_egg():
	print("Œuf récupéré !")
	carrying_egg = true
	target_position = null  # Arrête de se déplacer

	# Positionne l'œuf dans les mains en fonction du personnage
	held_egg.position = $AnimatedSprite2D.position + Vector2(20, -20)  
	held_egg.scale = Vector2(0.25, 0.25)  # Ajuste la taille de l'œuf
	held_egg.visible = true  # Affiche l'œuf lorsque le personnage le porte

# Fonction manquante ajoutée ici !
func update_animation(anim_set):
	var angle : float
	var slice_dir : int

	# Si le personnage ne bouge pas, l'angle de direction n'a pas besoin d'être calculé
	if last_direction.length() == 0:
		angle = 0
		slice_dir = 0  # Animation idle (face)
		$AnimatedSprite2D.play(anim_directions[anim_set][slice_dir][0])
		$AnimatedSprite2D.flip_h = anim_directions[anim_set][slice_dir][1]
		return

	# Calcule l'angle de direction
	angle = rad_to_deg(last_direction.angle())  
	slice_dir = int(floor((angle + 22.5) / 90)) % anim_directions[anim_set].size()
	
	# Joue l'animation appropriée
	$AnimatedSprite2D.play(anim_directions[anim_set][slice_dir][0])
	$AnimatedSprite2D.flip_h = anim_directions[anim_set][slice_dir][1]
