extends Node2D

# Variables de movimiento para cada bicicleta
var speeds = [0.0, 0.0, 0.0, 0.0] # Velocidades actuales de cada bicicleta
var accelerations = [200.0, 200.0, 200.0, 200.0] # Aceleraciones de cada bicicleta
var max_speeds = [400.0, 400.0, 400.0, 400.0] # Velocidades máximas de cada bicicleta
var frictions = [100.0, 100.0, 100.0, 100.0] # Fricciones para cada bicicleta

# Referencias a los cuatro sprites
@onready var sprite1 = $Control/SeccionPista/Biker1
@onready var sprite2 = $Control/SeccionPista/Biker2
@onready var sprite3 = $Control/SeccionPista/Biker3
@onready var sprite4 = $Control/SeccionPista/Biker4

@onready var seccion_pista = $Control/SeccionPista # Sección de la pista

# Función que se llama cada frame
func _process(delta):
	handle_input(delta)
	update_positions(delta)
	handle_screen_wrap()

# Manejo de la entrada del usuario para cada bicicleta
func handle_input(delta):
	# Maneja el control individual de cada bicicleta
	for i in range(4):
		if Input.is_action_pressed("gatillo_" + str(i + 1)): # Ejemplo: gatillo_1, gatillo_2, etc.
			speeds[i] += accelerations[i] * delta
			speeds[i] = min(speeds[i], max_speeds[i]) # Limita la velocidad a la máxima
		else:
			# Aplica fricción para reducir la velocidad cuando se suelta el "gatillo"
			speeds[i] -= frictions[i] * delta
			speeds[i] = max(speeds[i], 0) # La velocidad no baja de cero

# Actualiza las posiciones de cada bicicleta en el eje horizontal
func update_positions(delta):
	sprite1.position.x += speeds[0] * delta
	sprite2.position.x += speeds[1] * delta
	sprite3.position.x += speeds[2] * delta
	sprite4.position.x += speeds[3] * delta

# Función para manejar el envolvimiento de la pantalla para cada bicicleta
func handle_screen_wrap():
	var screen_width = get_viewport().size.x

	# Manejo del envolvimiento para cada bicicleta
	for sprite in [sprite1, sprite2, sprite3, sprite4]:
		if sprite.position.x > screen_width:
			sprite.position.x = 0
		elif sprite.position.x < 0:
			sprite.position.x = screen_width

# Función que se llama cuando el nodo está listo
func _ready():
	var middle_height = seccion_pista.get_rect().size.y
	sprite1.position = Vector2(100, middle_height / 10)
	sprite2.position = Vector2(100, middle_height / 3)
	sprite3.position = Vector2(100, middle_height * 2 / 3)
	sprite4.position = Vector2(100, middle_height * 9 / 10)# Muy cerca de la parte inferior
