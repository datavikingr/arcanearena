extends PlayerCharacter

#######################################################################################################################################################
## DECLARATIONS
# User settings on Player
func player_setup():
	player_color = "Yellow" # This is how we're going to assign players to characters, and a lot of the sprite/animation controls.
	player_index = 3 # Player 1's script gets device 0, required for player_aim() in input_handling()
	player_setting_deadzone = 0.25 # Player-tuned arcade-style on/off stick's deadzone
	player_input_left = "player4_left"
	player_input_right = "player4_right"
	player_input_down = "player4_down"
	player_input_up = "player4_up"
	player_input_A = "player4_jump"
	player_input_X = "player4_attack"
	player_input_B = "player4_block"
	player_input_Y = "player4_special"
