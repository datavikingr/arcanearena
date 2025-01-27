extends PlayerCharacter

#######################################################################################################################################################
## DECLARATIONS
# User settings on Player
func player_setup():
	player_color = "Purple" # This is how we're going to assign players to characters, and a lot of the sprite/animation controls.
	player_index = 0 # Player 1's script gets device 0, required for player_aim() in input_handling()
	player_setting_deadzone = 0.25 # Player-tuned arcade-style on/off stick's deadzone
	player_input_left = "player1_left"
	player_input_right = "player1_right"
	player_input_down = "player1_down"
	player_input_up = "player1_up"
	player_input_A = "player1_jump"
	player_input_X = "player1_attack"
	player_input_B = "player1_block"
	player_input_Y = "player1_special"
