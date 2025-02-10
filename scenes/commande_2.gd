extends Control

@onready var option_button: OptionButton = $OptionButton
@onready var http_request: HTTPRequest = $HTTPRequest

func _ready() -> void:
	# Connecter correctement le signal en Godot 4
	http_request.request_completed.connect(_on_request_completed)
	
	# Envoyer une requête GET à l'API des commandes
	var url = "https://symfony-back-kitchen-production.up.railway.app/api/v1/get_list_commandes_payes "
	var error = http_request.request(url)
	
	if error != OK:
		print("\u274c Erreur lors de la requête API :", error)

func _on_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code != 200:
		print("\u274c Erreur API, code :", response_code)
		return

	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())

	if parse_result != OK:
		print("\u274c Erreur de parsing JSON")
		print("Réponse brute :", body.get_string_from_utf8())  # Debugging
		return

	var data = json.data  # On suppose que c'est une liste d'objets
	
	# Vérification que la réponse est bien une liste
	if typeof(data) != TYPE_ARRAY:
		print("\u274c Format de données inattendu :", data)
		return

	option_button.clear()  # Vider l'OptionButton avant de le remplir

	for item in data:
		# Vérifier si chaque élément est un dictionnaire et si la clé "nomCommande" existe
		if typeof(item) == TYPE_DICTIONARY and item.has("nomCommande"):
			option_button.add_item(item["nomCommande"])  # Ajouter le nom de la commande à l'OptionButton
		else:
			print("⚠️ Clé 'nomCommande' manquante dans l'élément :", item)

func _on_option_button_item_selected(index: int) -> void:
	var selected_text = option_button.get_item_text(index)
	print("✅ Sélectionné :", selected_text)
