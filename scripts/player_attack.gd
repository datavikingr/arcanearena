extends StaticBody2D

#######################################################################################################################################################
## DECLARATIONS
# Nodes
@onready var instantiator = get_parent()
@onready var sprite: Sprite2D = $Sprite
@onready var collision_shape: CollisionShape2D = $PhysicsShape
@onready var animation_player: AnimationPlayer = $AnimationPlayer
# Local
var attack_frames: Array[int]
var blue_attack: Array[int] = [16, 17]
var green_attack: Array[int] = [40, 41]
var purple_attack: Array[int] = [64, 65]
var red_attack: Array[int] = [88, 89]
var yellow_attack: Array[int] = [112, 113]
var orange_attack: Array[int] = [136, 137]
var player_color: String
var anim_name: String
var anim: Animation

#######################################################################################################################################################
## EXECUTION / MAIN
func _ready() -> void: # Called when the node enters the scene tree for the first time.
	#player_color = instantiator.name
	print("Instantiated by:", player_color)
	match player_color: # omfg - I'm so glad I figured this match syntax out, this is gonna save my life, if this works right
		"Blue": attack_frames = blue_attack
		"Green": attack_frames = green_attack
		"Purple": attack_frames = purple_attack
		"Red": attack_frames = red_attack
		"Yellow": attack_frames = yellow_attack
		"Orange": attack_frames = orange_attack
	play_melee_animation()

func play_melee_animation():
	animation_player.stop()  # Stop any current animations
	anim = animation_player.get_animation("melee_attack")

	if anim: # Check if the animation exists
		print("found the animation")
		# Get the specific track for the sprite frame and collision shape size
		var sprite_track_index = anim.find_track(".:frame", Animation.TYPE_VALUE)
		print(sprite_track_index)
		var shape_radius_track_index = anim.find_track("../PhysicsShape:shape:radius", Animation.TYPE_VALUE)
		print(shape_radius_track_index)
		var shape_height_track_index = anim.find_track("../PhysicsShape:shape:height", Animation.TYPE_VALUE)
		print(shape_height_track_index)

		if sprite_track_index != -1: # Modify the tracks or insert keyframes, if necessary
			print("we found the sprite track")
			anim.track_insert_key(sprite_track_index, 0.0, attack_frames[0]) # Frame 0 at 0 seconds
			anim.track_insert_key(sprite_track_index, 0.5, attack_frames[1]) # Frame 1 at 0.5 seconds
			anim.track_insert_key(sprite_track_index, 2.5, attack_frames[0]) # Frame 0 at 2.5 seconds

		if shape_radius_track_index != -1 and shape_height_track_index != -1:
			print("we found the hitbox track")
			anim.track_insert_key(shape_radius_track_index, 0.0, 4)   # Start radius
			anim.track_insert_key(shape_radius_track_index, 0.5, 8)   # Larger radius for Frame[1]
			anim.track_insert_key(shape_radius_track_index, 2.5, 4)   # Return to start radius
			anim.track_insert_key(shape_height_track_index, 0.0, 8)   # Start height
			anim.track_insert_key(shape_height_track_index, 0.5, 16)  # Larger height for Frame[1]
			anim.track_insert_key(shape_height_track_index, 2.5, 8)   # Return to start height
	else:
		print("Animation 'melee_attack' not found.")

	animation_player.play("melee_attack")
	print("played the animation")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_timer_timeout() -> void:
	queue_free()
