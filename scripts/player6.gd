extends PlayerCharacter

#######################################################################################################################################################
## DECLARATIONS
# User settings on Player
func player_setup():
	player_color = "Orange" # This is how we're going to assign players to characters, and a lot of the sprite/animation controls.
	player_index = 5 # Player 1's script gets device 0, required for player_aim() in input_handling()
	player_setting_deadzone = 0.25 # Player-tuned arcade-style on/off stick's deadzone
	player_input_left = "player6_left"
	player_input_right = "player6_right"
	player_input_down = "player6_down"
	player_input_up = "player6_up"
	player_input_A = "player6_jump"
	player_input_X = "player6_attack"
	player_input_B = "player6_block"
	player_input_Y = "player6_special"
