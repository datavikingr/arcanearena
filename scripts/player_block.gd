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
var block_frames: Array[int]
var blue_block: Array[int] = [16+2, 17+2]
var green_block: Array[int] = [40+2, 41+2]
var purple_block: Array[int] = [64+2, 65+2]
var red_block: Array[int] = [88+2, 89+2]
var yellow_block: Array[int] = [112+2, 113+2]
var orange_block: Array[int] = [136+2, 137+2]
var anim_name: String
var anim: Animation

#######################################################################################################################################################
## STATUS-CHECK / CALLABLE FUNCTIONS
func has_common_group(other_body: Node) -> bool:
	for group in get_groups():
		if other_body.is_in_group(group):
			return true
	return false

#######################################################################################################################################################
## EXECUTION / MAIN
func _ready() -> void: # Called when the node enters the scene tree for the first time.
	self.name = "PlayerBlock_"+player_color
	#print("Instantiated by:", player_color)
	animation_length = timer.wait_time
	match player_color: # omfg - I'm so glad I figured this match syntax out, this is gonna save my life, if this works right
		"Blue": block_frames = blue_block
		"Green": block_frames = green_block
		"Purple": block_frames = purple_block
		"Red": block_frames = red_block
		"Yellow": block_frames = yellow_block
		"Orange": block_frames = orange_block
	play_block_animation()

func _process(_delta: float) -> void: # Called every frame. 'delta' is the elapsed time since the previous frame.
	pass

func play_block_animation():
	animation_player.stop()  # Stop any current animations
	anim = animation_player.get_animation("block")
	if anim: # Check if the animation exists
		#print("found the animation")
		var sprite_track_index = anim.find_track(".:frame", Animation.TYPE_VALUE) # Get the specific track for the sprite frame and collision shape size
		#print(sprite_track_index)
		var size_track_index = anim.find_track("../PhysicsShape:shape:size", Animation.TYPE_VALUE) # Get the specific track for the sprite frame and collision shape size
		#print(size_track_index)
		var key_zero = 0.0 # Start frame. Why? Consistency.
		var key_one = animation_length * 0.15
		var key_two = animation_length * 0.85
		if sprite_track_index != -1: # Modify the tracks or insert keyframes, if necessary
			#print("we found the sprite track")
			anim.track_insert_key(sprite_track_index, key_zero, block_frames[0]) # Frame 0 at 0 seconds
			anim.track_insert_key(sprite_track_index, key_one, block_frames[1]) # Frame 1 at 0.5 seconds
			anim.track_insert_key(sprite_track_index, key_two, block_frames[0]) # Frame 0 at 2.5 seconds
		if size_track_index != -1:
			#print("we found the hitbox track")
			var start_size: Vector2 = Vector2(6,11)
			var big_size: Vector2 = Vector2(14,7)
			anim.track_insert_key(size_track_index, key_zero, start_size)   # Start radius
			anim.track_insert_key(size_track_index, key_one, big_size)   # Larger radius for Frame[1]
			anim.track_insert_key(size_track_index, key_two, start_size)   # Return to start radius
	# else: #print("Animation 'block' not found.")
	animation_player.play("block")

#######################################################################################################################################################
## SINGALS
func _on_timer_timeout() -> void:
	queue_free()
