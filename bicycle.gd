extends Node2D

class_name Bicycle  # Para instanciarla fácilmente desde el editor

# Variables que controlan el estado interno de la bicicleta
var speed: float = 0.0
var max_speed: float = 400.0
var distance: float = 0.0

# Si quieres que la propia bicicleta maneje su sprite:
@onready var sprite_bike: Sprite2D = $Sprite2D

func _ready():
	# Aquí puedes inicializar variables o hacer configuraciones específicas.
	pass

func update_speed(new_speed: float):
	# Limita la velocidad a un máximo.
	speed = clamp(new_speed, 0, max_speed)

func update_position(delta: float):
	# Actualiza posición en X según la velocidad actual (km/h convertida a px/s si así lo deseas).
	# Por ejemplo, si speed está en km/h y 1 px = 1 "unidad" en Godot,
	# la conversión rápida sería: (km/h) * (1000 m / km) / (3600 s) ≈ m/s, 
	# pero puedes mantenerlo simple y tratar la velocidad como "px/s" si prefieres.
	position.x += speed * delta
	
	# Actualiza la distancia recorrida en kilómetros.
	# Para mantener la coherencia con tu código original:
	# distance += speed * (delta / 3600)  # km/h a km/s
	distance += speed * (delta / 3600)

func handle_screen_wrap(pista_start: float, pista_end: float):
	if position.x > pista_end:
		position.x = pista_start
	elif position.x < pista_start:
		position.x = pista_end
