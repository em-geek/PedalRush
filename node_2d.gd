extends Node2D

# Variables para el movimiento circular
var angle = 0.0
var radius = 100.0 # Radio del círculo
var baseRotationSpeed = 2.0 # Velocidad base de la rotación
var rotationSpeed = baseRotationSpeed # Velocidad de la rotación (modificable)

var rotation_center = Vector2() # Centro de la rotación (declarado sin inicializar)

@onready var sprite = $Sprite2D # Asegúrate de que el nodo se llama "Sprite2D"

# Función que se llama cuando el nodo está listo
func _ready():
	rotation_center = Vector2(400, 300) # Inicializamos el centro de la rotación

# Función para actualizar en cada frame
func _process(delta):
	handle_input(delta)

# Función para manejar la rotación basada en la entrada del usuario
func handle_input(delta):
	# Verifica si se debe acelerar
	if Input.is_action_pressed("gatillo"):
		rotationSpeed = baseRotationSpeed * 2 # Duplica la velocidad al presionar "ui_up"
	else:
		rotationSpeed = baseRotationSpeed # Regresa a la velocidad normal si no se presiona "ui_up"
	
	# Verifica si la tecla de rotación hacia la derecha está presionada
	if Input.is_action_pressed("ui_right"):
		rotate_sprite(delta, 1) # Rotar a la derecha
	elif Input.is_action_pressed("ui_left"):
		rotate_sprite(delta, -1) # Rotar a la izquierda

# Función para mover el sprite en un círculo, dirección 1 para derecha, -1 para izquierda
func rotate_sprite(delta, direction):
	angle += direction * rotationSpeed * delta # Cambia el ángulo en la dirección y velocidad correcta
	var new_position = Vector2(
		rotation_center.x + radius * cos(angle),
		rotation_center.y + radius * sin(angle)
	)
	sprite.position = new_position
