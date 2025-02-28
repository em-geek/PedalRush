extends Node2D

# Variables de movimiento para cada bicicleta
var speeds = [0.0, 0.0, 0.0, 0.0] # Velocidades actuales de cada bicicleta
var max_speeds = [400.0, 400.0, 400.0, 400.0] # Velocidades máximas de cada bicicleta

# Variables para distancia, tiempo y calorías
var distances = [0.0, 0.0, 0.0, 0.0] # Distancia recorrida por cada bicicleta (km)
var total_time = 0.0 # Tiempo total transcurrido (s)
var calorie_factor = 30.0 # Factor para calcular calorías quemadas por km
var save_interval = 60.0 # Intervalo de guardado en segundos 
var save_timer = 0.0

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
@onready var labelCaloriasB1 = $Control/SeccionInfo/InformacionRecorrido/InfoCalorias/LabelCB1
@onready var labelCaloriasB2 = $Control/SeccionInfo/InformacionRecorrido/InfoCalorias/LabelCB2
@onready var labelCaloriasB3 = $Control/SeccionInfo/InformacionRecorrido/InfoCalorias/LabelCB3
@onready var labelCaloriasB4 = $Control/SeccionInfo/InformacionRecorrido/InfoCalorias/LabelCB4

@onready var labelDistanciaB1 = $Control/SeccionInfo/InformacionRecorrido/InfoDistancia/LabelDB1
@onready var labelDistanciaB2 = $Control/SeccionInfo/InformacionRecorrido/InfoDistancia/LabelDB2
@onready var labelDistanciaB3 = $Control/SeccionInfo/InformacionRecorrido/InfoDistancia/LabelDB3
@onready var labelDistanciaB4 = $Control/SeccionInfo/InformacionRecorrido/InfoDistancia/LabelDB4

@onready var labelTiempo = $Control/SeccionInfo/InformacionRecorrido/InfoTiempo/LabelT

# Ruta al archivo JSON simulado
var data_url = "res://data.json"
var update_interval = 1.0 # Intervalo de actualización en segundos
var update_timer = 0.0

var lap_counts = [0, 0, 0, 0]  # Vueltas completadas por cada bicicleta
var laps_to_complete = 3  # Número de vueltas necesarias para terminar la carrera

var pista_start = 0  # Inicio de la pista
var pista_end = 1200  # Final de la pista

var race_finished = false  # Variable para saber si la carrera ha terminado


func _process(delta):
	update_timer += delta
	total_time += delta  # Incrementa el tiempo total
	save_timer += delta
	
	if race_finished:
		return
	
	if update_timer >= update_interval:
		update_timer = 0
		update_bicycle_speeds()
		
	if save_timer >= save_interval:
		save_timer = 0 
		save_data_to_json()

	update_positions(delta)
	handle_screen_wrap()
	update_positions_table()
	update_bicycle_data_labels()
	update_simulation_info(delta)  # Nueva función para actualizar calorías, distancia y tiempo

# Lee los datos del archivo JSON y actualiza las velocidades
func update_bicycle_speeds():
	if race_finished:
		return
	
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
	for i in range(4):
		var sprite = [sprite1, sprite2, sprite3, sprite4][i]
		if sprite.position.x > pista_end:
			sprite.position.x = pista_start  # Regresa al inicio
			lap_counts[i] += 1  # Aumenta la cuenta de vueltas
			check_race_completion()  # Verifica si alguien terminó la carrera
		elif sprite.position.x < pista_start:
			sprite.position.x = pista_end  # Aparece al final
			
# Actualiza la tabla de posiciones basándose en las distancias recorridas
func update_positions_table():
	# Ordena las bicicletas según la distancia recorrida (de mayor a menor)
	var sorted_distances = distances.duplicate()
	sorted_distances.sort()
	sorted_distances.reverse()  # Usar el método reverse() para invertir la lista

	# Encuentra los índices originales para las distancias ordenadas
	var sorted_indexes = []
	for distance in sorted_distances:
		sorted_indexes.append(distances.find(distance))
		
	# Aplicar efecto de glow solo al ciclista en primer lugar
	var first_place_index = sorted_indexes[0]
	var sprites = [sprite1, sprite2, sprite3, sprite4]

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
	var total_caloriesB1 = distances[0] * calorie_factor
	var total_caloriesB2 = distances[1] * calorie_factor
	var total_caloriesB3 = distances[2] * calorie_factor
	var total_caloriesB4 = distances[3] * calorie_factor

	# Actualiza los Labels
	if labelDistanciaB1:
		labelDistanciaB1.text = "Distancia: %.2f km" % distances[0]
	if labelDistanciaB2:
		labelDistanciaB2.text = "Distancia: %.2f km" % distances[1]
	if labelDistanciaB3:
		labelDistanciaB3.text = "Distancia: %.2f km" % distances[2]
	if labelDistanciaB4:
		labelDistanciaB4.text = "Distancia: %.2f km" % distances[3]
		
	if labelCaloriasB1:
		labelCaloriasB1.text = "Calorías Quemadas: %.2f kcal" % total_caloriesB1
	if labelCaloriasB2:
		labelCaloriasB2.text = "Calorías Quemadas: %.2f kcal" % total_caloriesB2
	if labelCaloriasB3:
		labelCaloriasB3.text = "Calorías Quemadas: %.2f kcal" % total_caloriesB3
	if labelCaloriasB4:
		labelCaloriasB4.text = "Calorías Quemadas: %.2f kcal" % total_caloriesB4
		
	if labelTiempo:
		labelTiempo.text = "Tiempo: %02d:%02d" % [int(total_time / 60), int(total_time) % 60]

func check_race_completion():
	for i in range(4):
		if lap_counts[i] >= laps_to_complete:
			print("¡Bicicleta", i + 1, "ha terminado la carrera!")
			speeds[i] = 0  # Detener la bicicleta ganadora
			race_finished = true  # Marcar que la carrera ha terminado
			stop_simulation()  # Llamar a una función para detener la simulación
			break  # Detener el ciclo al encontrar un ganador

func save_data_to_json(): 
 		# Obtener la fecha y hora actuales 
		var current_date = Time.get_datetime_dict_from_system()
		var formatted_date = "%d-%02d-%02d %02d:%02d:%02d" % [current_date.year, current_date.month, current_date.day, current_date.hour, current_date.minute, current_date.second] 
		
		
		# Crear un diccionario para los datos 
		var data = { 
			"datetime": formatted_date, 
			"time": total_time, 
			"bicycles": [] 
		} 
		# Añadir datos de cada bicicleta 
		for i in range(4): 
			data["bicycles"].append({ 
				"bicycle": i + 1, 
				"distance": distances[i], 
				"calories": distances[i] * calorie_factor 
			}) 
			
		 # Leer los datos anteriores del archivo JSON, si existe 
		var log_data = {"logs": []} 
		if FileAccess.file_exists("user://log_data.json"): 
			var file = FileAccess.open("user://log_data.json", FileAccess.READ) 
			var content = file.get_as_text() 
			file.close()
			 
			var json_parser = JSON.new() 
			var parse_result = json_parser.parse(content) 
			if parse_result == OK: 
				log_data = json_parser.get_data() 
			else: 
				print("Error al parsear JSON:", json_parser.error_string) 
				
		 # Si 'logs' no existe en log_data, crearlo 
		if not log_data.has("logs"): 
			log_data["logs"] = []
				
		# Añadir el nuevo registro 
		log_data["logs"].append(data) 
		
		# Convertir el diccionario a JSON y formatearlo con indentación 
		var json_formatter = JSON.new()
		var json_data = json_formatter.stringify(log_data, "\t")
		
		# Guardar los datos en un archivo 
		var file = FileAccess.open("res://log_data.json", FileAccess.WRITE) 
		file.store_string(json_data + "\n") # Añadir salto de línea para mejorar la legibilidad 
		file.close() 
		print("Datos guardados en log_data.json")

# Detener la simulación si la carrera ha terminado
func stop_simulation():
	if race_finished:
		speeds = [0, 0, 0, 0]  # Detener todas las bicicletas
		print("La carrera ha terminado.")
