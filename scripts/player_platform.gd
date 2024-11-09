extends StaticBody2D

#######################################################################################################################################################
## DECLARATIONS
# Nodes
@onready var sprite: Sprite2D = $Sprite
@onready var collision_shape: CollisionShape2D = $PhysicsShape
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer
# Exports
@export var animation_length: float
# Local
var player_color: String
var platform_frames: Array[int]
var blue_platform: Array[int] = [16, 17] # Needs -90 sprite rotation
var green_platform: Array[int] = [40, 41] # Needs -90 sprite rotation
var purple_platform: Array[int] = [64+2, 65+2] # Good as is
var red_platform: Array[int] = [88+2, 88+2] # Needs 90 sprite rotation
var yellow_platform: Array[int] = [112+2, 113+2] # Good as is
var orange_platform: Array[int] = [136+2, 137+2] # Needs 90 sprite rotation
var anim_name: String
var anim: Animation

#######################################################################################################################################################
## STATUS-CHECK / CALLABLE FUNCTIONS

#######################################################################################################################################################
## EXECUTION / MAIN
func _ready() -> void: # Called when the node enters the scene tree for the first time.
	self.name = "PlayerPlatform_"+player_color
	#print("Instantiated by:", player_color)
	animation_length = timer.wait_time # Pull the time from the node, so we don't have to edit multiple places for one change.
	match player_color: # omfg - I'm so glad I figured this match syntax out, this is gonna save my life, if this works right
		"Blue":
			platform_frames = blue_platform
			sprite.rotation -= -PI/2
		"Green":
			platform_frames = green_platform
			sprite.rotation -= -PI/2
		"Purple":
			platform_frames = purple_platform
		"Red":
			platform_frames = red_platform
			sprite.rotation -= -PI/2
		"Yellow":
			platform_frames = yellow_platform
		"Orange":
			platform_frames = orange_platform
			sprite.rotation -= -PI/2
	play_platform_animation() # After Init(), call Main()

func _process(_delta: float) -> void: # Called every frame. 'delta' is the elapsed time since the previous frame.
	pass # We don't need a second thread here yet.

func play_platform_animation():
	animation_player.stop()  # Stop any current animations
	anim = animation_player.get_animation("platform") # Get the animation we want to set up
	if anim: # Check if the animation exists
		var sprite_track_index = anim.find_track(".:frame", Animation.TYPE_VALUE) # Get the specific track for the sprite frame and collision shape size
		var size_track_index = anim.find_track("../PhysicsShape:shape:size", Animation.TYPE_VALUE) # Get the specific track for the sprite frame and collision shape size
		var key_zero = 0.0 # Start frame. Why? Consistency.
		var key_one = animation_length * 0.15 # 15%
		var key_two = animation_length * 0.85 # 85%
		if sprite_track_index != -1: # Modify the tracks or insert keyframes, if necessary
			anim.track_insert_key(sprite_track_index, key_zero, platform_frames[0]) # Frame 0 at 0 seconds
			anim.track_insert_key(sprite_track_index, key_one, platform_frames[1]) # Frame 1 at 0.5 seconds
			anim.track_insert_key(sprite_track_index, key_two, platform_frames[0]) # Frame 0 at 2.5 seconds
		if size_track_index != -1: # If we found the track
			var start_size: Vector2 = Vector2(6,11) # smaller
			var big_size: Vector2 = Vector2(14,7) # bigger
			anim.track_insert_key(size_track_index, key_zero, start_size)   # Start radius
			anim.track_insert_key(size_track_index, key_one, big_size)   # Larger radius for Frame[1]
			anim.track_insert_key(size_track_index, key_two, start_size)   # Return to start radius
	animation_player.play("platform") # run the animation we just set up

#######################################################################################################################################################
## SINGALS
func _on_timer_timeout() -> void:
	queue_free() # on timeout, die.
