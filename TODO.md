./scripts/player_behavior.gd:549:	
# Y Button - Special TODO: Needs implementation - not here, down at player_special()

./scripts/player_behavior.gd:750:
func player_block() -> void: # Called by state_machine(); Localized magic wall for defense #TODO: Make the block magic bigger.

./scripts/player_behavior.gd:789:
func player_special() -> void: # TODO Called by state_machine(); The Player is spending their 'smash ball' scroll

./scripts/player_behavior.gd:808:
func player_score(player_name) -> void: # TODO?? Maybe a celebration animation?

./scripts/player_missile.gd:61:				
#TODO: probably emit signal to body: player_hurt, and then have to build the player hurt animation, knockback (.75 seconds), tie it into UI, death animation, respawn timer.

./scripts/cold_goal.gd:22:			
players = [player1, player2] #TODO: Replace with dynamic detection of players

./scripts/player_attack.gd:44:	
elif body.is_in_group("players"): # Then we need to be able to do damage TODO

./scripts/player_attack.gd:48:				
#TODO: probably emit signal to body: player_hurt, and then have to build the player hurt animation, knockback (.75 seconds), tie it into UI, death animation, respawn timer.

./scripts/ball.gd:52:				
#TODO We need the ball to stop interacting with physics, disappear, and reset position.

./scripts/ball.gd:54:				
#TODO: We gotta figure out this possession and on fire idea

./scripts/ball.gd:110:
func write_gitgud_message() -> void: #TODO

./scripts/hot_goal.gd:22:			
players = [player1, player2] #TODO: Replace with dynamic detection of players

finish ball on fire - both for what happens (above) and switching to team posession.

Finish on-map win screen, begin prep for post-map win screen. 

Start collecting shot data for post-map win screen.

Logo splash screen

Main menu (keep it simple to start out)

Add pause function

Begin building new maps
