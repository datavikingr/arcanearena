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
var anim_name: String
var anim: Animation

#######################################################################################################################################################
## STATUS-CHECK / CALLABLE FUNCTIONS

#######################################################################################################################################################
## EXECUTION / MAIN
func _ready() -> void: # Called when the node enters the scene tree for the first time.
	self.name = "PlayerBlock_"+player_color
	anim_name = player_color.to_lower() + "_block"
	animation_player.play(anim_name) # Play what we just assembled

func _process(_delta: float) -> void: # Called every frame. 'delta' is the elapsed time since the previous frame.
	pass # We don't need a second thread here yet.

#######################################################################################################################################################
## SINGALS
func _on_timer_timeout() -> void:
	queue_free() # on timeout, die.
