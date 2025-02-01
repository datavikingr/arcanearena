extends RigidBody2D

#######################################################################################################################################################
## DECLARATIONS
# Nodes
@onready var sprite: Sprite2D = $Sprite
@onready var collision_shape: CollisionShape2D = $PhysicsShape
@onready var animation_player: AnimationPlayer = $AnimationPlayer
# Local
var player_color: String
var anim_name: String
var anim: Animation
var attack_force: float = 750.0
# Signals
signal enemy_contact

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
	self.name = "PlayerAttack_"+player_color # So we can find others when we instantiate the attack.
	anim_name = player_color.to_lower() + "_attack"
	animation_player.play(anim_name) # Play what we just assembled

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass # We don't need a second thread here yet.

func _on_timer_timeout() -> void:
	queue_free() # gets removed after 1 seconds. See Node:PlayerAttack/Timer

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("balls"): # Assuming the ball is in a group called "balls"
		var attack_direction = (body.global_position - global_position).normalized() # Normalize direction
		var attack = attack_direction * attack_force # Multiply normalized direction by the desired force
		body.apply_central_impulse(attack) # Apply the force to the ball
	elif body.is_in_group("players"): # Then we need to be able to do damage TODO
		if body.name != player_color: # Make sure it's not self contact
			if not has_common_group(body): # Doesn't belong to the same group as self
				#print("We have enemy contact!") # Debug
				#TODO: probably emit signal to body: player_hurt, and then have to build the player hurt animation, knockback (.75 seconds), tie it into UI, death animation, respawn timer.
				self.enemy_contact.connect(Callable(body,"player_hurt"))
				enemy_contact.emit()
				queue_free()
				pass
			else: # Friendly fire, no effect.
				#print("Friendly Fire!") # Debug
				pass
