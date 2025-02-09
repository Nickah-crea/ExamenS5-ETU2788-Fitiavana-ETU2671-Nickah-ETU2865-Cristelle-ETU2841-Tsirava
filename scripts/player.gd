extends CharacterBody2D

const MOTION_SPEED = 160 # Pixels/second.
var last_direction = Vector2(1, 0)

var target_position = null  # Position de l'œuf quand cliqué
var carrying_egg = false  # Indique si l'œuf est porté

var anim_directions = {
	"idle": [ ["front_idle", false] ],
	"walk": [ ["side_right_walk", false], ["front_walk", false], ["side_left_walk", false], ["back_walk", false] ],
}

func _ready():
	# Connecte le signal de l'œuf
	var egg = get_node_or_null("/root/MainScene/Egg")  # Assure-toi du bon chemin vers l'œuf
	if egg:
		egg.egg_clicked.connect(on_egg_clicked)

func on_egg_clicked(egg_pos):
	target_position = egg_pos  # Définit la cible du déplacement

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

func carry_egg():
	print("Œuf récupéré !")
	carrying_egg = true
	target_position = null  # Arrête de se déplacer

# 💡 Fonction manquante ajoutée ici !
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
