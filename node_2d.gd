extends Node2D

# Variables de movimiento para cada bicicleta
var speeds = [0.0, 0.0, 0.0, 0.0] # Velocidades actuales de cada bicicleta
var max_speeds = [400.0, 400.0, 400.0, 400.0] # Velocidades máximas de cada bicicleta

# Variables para distancia, tiempo y calorías
var distances = [0.0, 0.0, 0.0, 0.0] # Distancia recorrida por cada bicicleta (km)
var total_time = 0.0 # Tiempo total transcurrido (s)
var calorie_factor = 30.0 # Factor para calcular calorías quemadas por km

# Referencias a los cuatro sprites
@onready var sprite1 = $Control/SeccionPista/Biker1
@onready var sprite2 = $Control/SeccionPista/Biker2
@onready var sprite3 = $Control/SeccionPista/Biker3
@onready var sprite4 = $Control/SeccionPista/Biker4

# Referencias a las etiquetas de "Datos"
@onready var label_datos_bici1 = $Control/SeccionJugadores/Datos/DatoBicicleta1/CenterContainer/DatosBici1
@onready var label_datos_bici2 = $Control/SeccionJugadores/Datos/DatoBicicleta2/CenterContainer/DatosBici2
@onready var label_datos_bici3 = $Control/SeccionJugadores/Datos/DatoBicicleta3/CenterContainer/DatosBici3
@onready var label_datos_bici4 = $Control/SeccionJugadores/Datos/DatoBicicleta4/CenterContainer/DatosBici4

# Referencias a las etiquetas de posiciones
@onready var label1 = $Control/SeccionInfo/TablaPosicion/indicador/Label1
@onready var label2 = $Control/SeccionInfo/TablaPosicion/indicador2/Label2
@onready var label3 = $Control/SeccionInfo/TablaPosicion/indicador3/Label3
@onready var label4 = $Control/SeccionInfo/TablaPosicion/indicador4/Label4

# Informacion sobre Distancia, Tiempo y Calorias
@onready var labelCalorias = $Control/SeccionInfo/InformacionRecorrido/InfoTiempo/LabelT
@onready var labelDistancia = $Control/SeccionInfo/InformacionRecorrido/InfoDistancia/LabelD
@onready var labelTiempo = $Control/SeccionInfo/InformacionRecorrido/InfoCalorias/LabelC

# Ruta al archivo JSON simulado
var data_url = "res://data.json"
var update_interval = 1.0 # Intervalo de actualización en segundos
var update_timer = 0.0

func _process(delta):
	update_timer += delta
	total_time += delta  # Incrementa el tiempo total
	if update_timer >= update_interval:
		update_timer = 0
		update_bicycle_speeds()

	update_positions(delta)
	handle_screen_wrap()
	update_positions_table()
	update_bicycle_data_labels()
	update_simulation_info(delta)  # Nueva función para actualizar calorías, distancia y tiempo

# Lee los datos del archivo JSON y actualiza las velocidades
func update_bicycle_speeds():
	if FileAccess.file_exists(data_url):
		var content = FileAccess.get_file_as_string(data_url)
		var json_parser = JSON.new()
		var parse_result = json_parser.parse(content)
		if parse_result == OK:
			var json_data = json_parser.get_data()
			var bicycles = json_data["bicycles"]
			for i in range(min(bicycles.size(), speeds.size())):
				speeds[i] = clamp(bicycles[i]["speed"], 0, max_speeds[i])
		else:
			print("Error al parsear JSON:", json_parser.error_string)
	else:
		print("Archivo JSON no encontrado en:", data_url)

# Actualiza las posiciones de cada bicicleta en el eje horizontal
func update_positions(delta):
	for i in range(4): 
		# Calcula la distancia recorrida para cada bicicleta 
		var distance_delta = speeds[i] * (delta / 3600) # Convierte la velocidad de km/h a km/s 
		distances[i] += distance_delta
	# Actualiza las posiciones
	sprite1.position.x += speeds[0] * delta
	sprite2.position.x += speeds[1] * delta
	sprite3.position.x += speeds[2] * delta
	sprite4.position.x += speeds[3] * delta

# Función para manejar el envolvimiento de la pantalla para cada bicicleta
func handle_screen_wrap():
	var pista_start = 0  # Inicio de la pista
	var pista_end = 890  # Final de la pista

	for sprite in [sprite1, sprite2, sprite3, sprite4]:
		if sprite.position.x > pista_end:
			sprite.position.x = pista_start  # Regresa al inicio
		elif sprite.position.x < pista_start:
			sprite.position.x = pista_end  # Aparece al final

# Actualiza la tabla de posiciones
func update_positions_table():
	var positions = [sprite1.position.x, sprite2.position.x, sprite3.position.x, sprite4.position.x]
	var sorted_indexes = []
	var sorted_positions = positions.duplicate()
	sorted_positions.sort()

	for pos in sorted_positions:
		sorted_indexes.append(positions.find(pos))

	# Actualiza las etiquetas con las posiciones
	label1.text = "Bicicleta " + str(sorted_indexes.find(0) + 1) + " (Primero)"
	label2.text = "Bicicleta " + str(sorted_indexes.find(1) + 1) + " (Segundo)"
	label3.text = "Bicicleta " + str(sorted_indexes.find(2) + 1) + " (Tercero)"
	label4.text = "Bicicleta " + str(sorted_indexes.find(3) + 1) + " (Cuarto)"

# Actualiza las etiquetas de velocidad de las bicicletas en "Datos"
func update_bicycle_data_labels():
	if label_datos_bici1:
		label_datos_bici1.text = "🚴‍♂️ Bicicleta 1\nVelocidad: " + str(speeds[0]) + " km/h"
		label_datos_bici1.add_theme_color_override("font_color", Color(1, 0, 0))  # Color rojo
		label_datos_bici1.add_theme_font_size_override("font_size", 9)
		label_datos_bici1.visible = true

	if label_datos_bici2:
		label_datos_bici2.text = "🚴‍♂️ Bicicleta 2\nVelocidad: " + str(speeds[1]) + " km/h"
		label_datos_bici2.add_theme_color_override("font_color", Color(0, 1, 0))  # Color verde
		label_datos_bici2.add_theme_font_size_override("font_size", 9)
		label_datos_bici2.visible = true

	if label_datos_bici3:
		label_datos_bici3.text = "🚴‍♂️ Bicicleta 3\nVelocidad: " + str(speeds[2]) + " km/h"
		label_datos_bici3.add_theme_color_override("font_color", Color(0, 0, 1))  # Color azul
		label_datos_bici3.add_theme_font_size_override("font_size", 9)
		label_datos_bici3.visible = true

	if label_datos_bici4:
		label_datos_bici4.text = "🚴‍♂️ Bicicleta 4\nVelocidad: " + str(speeds[3]) + " km/h"
		label_datos_bici4.add_theme_color_override("font_color", Color(1, 1, 0))  # Color amarillo
		label_datos_bici4.add_theme_font_size_override("font_size", 9)
		label_datos_bici4.visible = true
		
# Actualiza solo la información de la simulación para la Bicicleta 1
func update_simulation_info(delta):

	# Calcula las calorías quemadas por la primera bicicleta
	var total_calories = distances[0] * calorie_factor

	# Actualiza los Labels
	if labelDistancia:
		labelDistancia.text = "Distancia:\n %.2f km" % distances[0]
	if labelCalorias:
		labelCalorias.text = "Calorías Quemadas:\n %.2f kcal" % total_calories
	if labelTiempo:
		labelTiempo.text = "Tiempo:\n %02d:%02d" % [int(total_time / 60), int(total_time) % 60]
