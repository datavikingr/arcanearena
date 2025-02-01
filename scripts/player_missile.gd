extends RigidBody2D

#######################################################################################################################################################
## DECLARATIONS
#Nodes
@onready var sprite: Sprite2D = $Sprite
#Local
var player_color: String # who made the bloody thing, so we can change sprite during ready()
var direction: Vector2 # what it says on the can, the direction of travel
var speed = 400 # also hit force
# Sprite Frame Data
var missile_frame: int
var blue_missile: int = 23
var green_missile: int = 47
var purple_missile: int = 71
var red_missile: int = 95
var yellow_missile: int = 119
var orange_missile: int = 143
#Signals
signal enemy_missile_contact

#######################################################################################################################################################
## STATUS-CHECK / CALLABLE FUNCTIONS
func has_common_group(other_body: Node) -> bool: # Team-check; Used in on_body_entered()
	for group in get_groups():
		if other_body.is_in_group(group):
			return true
	return false

#######################################################################################################################################################
## EXECUTION / MAIN
func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	self.name = "PlayerMissile_"+player_color # So we can find others when we instantiate the attack.
	match player_color: # omfg - I'm so glad I figured this match syntax out, this is gonna save my life, if this works right
		"Blue": missile_frame = blue_missile
		"Green": missile_frame = green_missile
		"Purple": missile_frame = purple_missile
		"Red": missile_frame = red_missile
		"Yellow": missile_frame = yellow_missile
		"Orange": missile_frame = orange_missile
	sprite.frame = missile_frame # Actually set the sprite for the correct player. Nothing fancy, no additional frames.

func _physics_process(_delta: float) -> void:
	linear_velocity = direction * speed # Or manually move it each frame if you want to handle the movement directly

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("balls"):
		var force_vector = direction * speed # Multiply direction by the desired force
		body.apply_central_impulse(force_vector) # Apply the force to the ball
		queue_free()
	elif body.is_in_group("players"):# and not body.is_in_group("ColdTeam"): # Assuming you are firing as a ColdTeam player
		print("We have player contact!")
		if body.name != player_color: # Make sure it's not self contact
			print("We didn't hit the missile ourselves")
			if not has_common_group(body): # Doesn't belong to the same group as self
				print("We have enemy contact!") # Debug
				self.enemy_missile_contact.connect(Callable(body, "player_hurt"))
				enemy_missile_contact.emit()
				queue_free()
				#TODO: probably emit signal to body: player_hurt, and then have to build the player hurt animation, knockback (.75 seconds), tie it into UI, death animation, respawn timer.
			else: # Friendly fire, no effect.
				print("Friendly Fire!") # Debug
				queue_free()
	else: #Non-ball, non-player contact, likely a wall
		queue_free() # Destroy the projectile after collision
