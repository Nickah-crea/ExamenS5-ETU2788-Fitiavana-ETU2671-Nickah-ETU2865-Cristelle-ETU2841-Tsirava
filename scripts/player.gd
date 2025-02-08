extends CharacterBody2D

const MOTION_SPEED = 160 # Pixels/second.

var last_direction = Vector2(1, 0)

var anim_directions = {
	"idle": [ # list of [animation name, horizontal flip]
		["front_idle", false],
	],

	"walk": [
		["side_right_walk", false],
		["front_walk", false],
		["side_left_walk", false],
		["back_walk", false],
	],
}

func _physics_process(_delta):
	var motion = Vector2()
	motion.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	motion.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	motion = motion.normalized() * MOTION_SPEED

	# Mise à jour de la vitesse et du mouvement
	set_velocity(motion)
	move_and_slide()

	# Si le personnage bouge, on met à jour la direction et l'animation
	if motion.length() > 0:
		last_direction = motion
		update_animation("walk")
	else:
		# Animation idle : le personnage ne tourne pas s'il ne bouge pas
		update_animation("idle")


func update_animation(anim_set):
	var angle : float
	var slice_dir : int

	# Si le personnage ne bouge pas, l'angle de direction n'a pas besoin d'être calculé
	if last_direction.length() == 0:
		# L'angle de l'animation idle peut être fixe (0) pour éviter toute rotation
		angle = 0
		slice_dir = 0 # Par défaut, on choisit l'animation de face pour idle
		$AnimatedSprite2D.play(anim_directions[anim_set][slice_dir][0])
		$AnimatedSprite2D.flip_h = anim_directions[anim_set][slice_dir][1]
		return

	# Calcule l'angle de la direction de déplacement
	angle = rad_to_deg(last_direction.angle()) # Utilisation correcte de l'angle
	# Maintenant, on divise l'angle en 4 directions principales (0, 90, 180, 270)
	slice_dir = int(floor((angle + 22.5) / 90)) % anim_directions[anim_set].size() # Conversion de slice_dir en entier avant le modulo
	
	# Joue l'animation appropriée
	$AnimatedSprite2D.play(anim_directions[anim_set][slice_dir][0])
	$AnimatedSprite2D.flip_h = anim_directions[anim_set][slice_dir][1]
