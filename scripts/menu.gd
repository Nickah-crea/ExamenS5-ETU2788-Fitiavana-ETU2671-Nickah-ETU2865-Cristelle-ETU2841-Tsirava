extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	var button = Button.new()
	button.text = "Menu"
	button.pressed.connect(self._button_pressed)
	add_child(button)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
