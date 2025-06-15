extends PlayerCharacter

#######################################################################################################################################################
## DECLARATIONS
# User settings on Player
func player_setup():
	player_color = "Purple" # This is how we're going to assign players to characters, and a lot of the sprite/animation controls.
	player_index = 4 # Player 1's script gets device 0, required for player_aim() in input_handling()
	player_setting_deadzone = 0.25 # Player-tuned arcade-style on/off stick's deadzone
	player_input_left = "player5_left"
	player_input_right = "player5_right"
	player_input_down = "player5_down"
	player_input_up = "player5_up"
	player_input_A = "player5_jump"
	player_input_X = "player5_attack"
	player_input_B = "player5_block"
	player_input_Y = "player5_special"
