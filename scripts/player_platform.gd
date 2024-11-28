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
var platform_frames: int
var blue_platform: int = 17 # Needs -90 sprite rotation
var green_platform: int = 41 # Needs -90 sprite rotation
var purple_platform: int = 67 # Good as is
var red_platform: int = 90 # Needs 90 sprite rotation
var yellow_platform: int = 115 # Good as is
var orange_platform: int = 139 # Needs 90 sprite rotation
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
	sprite.frame = platform_frames

func _process(_delta: float) -> void: # Called every frame. 'delta' is the elapsed time since the previous frame.
	pass # We don't need a second thread here yet.

#######################################################################################################################################################
## SINGALS
func _on_timer_timeout() -> void:
	queue_free() # on timeout, die.
