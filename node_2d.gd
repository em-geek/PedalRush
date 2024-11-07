extends Node2D

# Variables para el movimiento
var speed = 0.0 # Velocidad actual de la bicicleta
var max_speed = 400.0 # Velocidad máxima
var acceleration = 200.0 # Aceleración al pedalear
var friction = 100.0 # Fricción cuando se suelta el acelerador

@onready var sprite = $Control/SeccionPista/Sprite2D # Asegúrate de que el nodo se llama "Sprite2D"
@onready var seccion_pista = $Control/SeccionPista # Asegúrate de que el nodo se llama "SeccionPista"

# Función que se llama cada frame
func _process(delta):
	handle_input(delta)
	update_position(delta)
	handle_screen_wrap() # Llamamos a la función para el envolvimiento

# Manejo de la entrada del usuario
func handle_input(delta):
	# Aumenta la velocidad cuando se presiona "gatillo" (simulando el pedaleo)
	if Input.is_action_pressed("gatillo"):
		speed += acceleration * delta
		speed = min(speed, max_speed) # Limita la velocidad a la máxima
	else:
		# Aplica fricción para reducir la velocidad cuando se suelta "gatillo"
		speed -= friction * delta
		speed = max(speed, 0) # La velocidad no baja de cero

# Actualiza la posición en el eje horizontal
func update_position(delta):
	sprite.position.x += speed * delta
	
# Función para manejar el envolvimiento de la pantalla
func handle_screen_wrap():
	# Obtener el tamaño de la ventana (tamaño de la pantalla)
	var screen_width = get_viewport().size.x
	var screen_height = get_viewport().size.y
	
	# Si el sprite se mueve fuera de la pantalla por la derecha
	if sprite.position.x > screen_width:
		sprite.position.x = 0 # Vuelve a aparecer en el lado izquierdo

	# Si el sprite se mueve fuera de la pantalla por la izquierda
	elif sprite.position.x < 0:
		sprite.position.x = screen_width # Vuelve a aparecer en el lado derecho
	
	# Si el sprite se mueve fuera de la pantalla por abajo
	if sprite.position.y > screen_height:
		sprite.position.y = 0 # Vuelve a aparecer en la parte superior

	# Si el sprite se mueve fuera de la pantalla por arriba
	elif sprite.position.y < 0:
		sprite.position.y = screen_height # Vuelve a aparecer en la parte inferior

# Función que se llama cuando el nodo está listo
func _ready():
	var middle_height = seccion_pista.get_rect().size.y
	sprite.position = Vector2(100, middle_height / 2) # Ajuste de altura
