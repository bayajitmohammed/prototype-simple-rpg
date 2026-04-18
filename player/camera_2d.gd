extends Camera2D


var shake_intensify: float = 0.0
var active_shake_time: float = 0.0

var shake_decay: float = 5.0

var shake_time: float = 0.0
var shake_time_speed: float = 20.0

var noise: FastNoiseLite = FastNoiseLite.new()

func _ready() -> void:
	var screen_size: Vector2 = get_viewport_rect().size
	limit_right = screen_size.x
	limit_bottom = screen_size.y
	
	
func _physics_process(delta: float) -> void:
	if  active_shake_time > 0:
		shake_time += delta * shake_time_speed
		active_shake_time -= delta
		
		offset = Vector2(
			noise.get_noise_2d(shake_time, 0) * shake_intensify,
			noise.get_noise_2d(0, shake_time) * shake_intensify
		)
		
		shake_intensify = max(shake_intensify - shake_decay * delta, 0)
	else:
		offset = lerp(offset, Vector2.ZERO, 10.5 * delta)
	

func screen_shake(intensity: int, time: float):
	randomize()
	noise.seed = randi()
	noise.frequency = 2.0
	
	shake_intensify = intensity
	active_shake_time = time
	shake_time = 0.0
