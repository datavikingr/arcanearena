extends CharacterBody2D

@export var speed: int = 200 # Feels like a good lateral speed for now.
@export var jump_speed: int = 300 # 400 is a little too high for the maps. 300 feels good.
@onready var sprite_wiz_blue = get_node("Sprite")
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") # gravity = 980
var is_holding = false
var left_right: float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta) -> void: 
	player_movement(delta)
	#if Input.is_action_just_pressed("blue_jump"):		## Handled in player_movement()
	#	player_jump(delta)								## Placeholder for clarity
	if Input.is_action_just_pressed("blue_attack"):
		player_attack(delta)
	if Input.is_action_just_pressed("blue_special"):
		player_special(delta)
	if Input.is_action_just_pressed("blue_block"):
		player_block(delta)

func player_movement(delta) -> void:
	velocity.y += gravity * delta
	# Move direction
	left_right = Input.get_axis("blue_left", "blue_right")
	velocity.x = left_right * speed
	# Sprite Directionality; sprite faces right by default
	if Input.is_action_just_pressed("blue_left"):
		sprite_wiz_blue.flip_h = true # toggles mirror on; faces left
	elif Input.is_action_just_pressed("blue_right"):
		sprite_wiz_blue.flip_h = false # toggles mirror off; faces right
	# Jump 
	if Input.is_action_just_pressed("blue_jump") and not Input.is_action_pressed("blue_down"):
		velocity.y = -1 * jump_speed #omg Godot defines "Up" as -Y and NOT +Y. *sigh* 
		print("Jump!")
	# Slide
	if Input.is_action_pressed("blue_down") and Input.is_action_pressed("blue_jump"):
		if sprite_wiz_blue.flip_h == true:
			left_right = -1
		else:
			left_right = 1
		velocity.x = left_right * speed * 2
	# Move
	move_and_slide()
	
func player_attack(_delta) -> void:
	print("Attack!")

func player_special(_delta) -> void:
	print("Special!")

func player_block(_delta) -> void:
	print("Block!")
