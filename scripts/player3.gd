extends PlayerCharacter

#######################################################################################################################################################
## DECLARATIONS
# User settings on Player
func player_setup():
	player_color = "Green" # This is how we're going to assign players to characters, and a lot of the sprite/animation controls.
	player_index = 2 # Player 1's script gets device 0, required for player_aim() in input_handling()
	player_setting_deadzone = 0.25 # Player-tuned arcade-style on/off stick's deadzone
	player_input_left = "player3_left"
	player_input_right = "player3_right"
	player_input_down = "player3_down"
	player_input_up = "player3_up"
	player_input_A = "player3_jump"
	player_input_X = "player3_attack"
	player_input_B = "player3_block"
	player_input_Y = "player3_special"
