# Finish on-map win screen, begin prep for post-map win screen. 

# Logo splash screen

# Main menu (keep it simple to start out)

# Add pause function

# Build new map formats

# Team Win Objects (cold/hot_team_wins.tscn)
./scripts/cold_team_wins.gd:#TODO switch to menu controls
./scripts/cold_team_wins.gd:#get_tree().change_scene_to_file("res://scenes/new_scene.tscn") #TODO

./scripts/hot_team_wins.gd:#TODO switch to menu controls
./scripts/hot_team_wins.gd:	#get_tree().change_scene_to_file("res://scenes/new_scene.tscn") #TODO

# Spells
./scripts/sudden_death.gd:#TODO Currently busted, needs work. hot_team_ui isn't loaded by sudden_death() or something

Basically none of these spells are properly tested

# Player/Player Sprite
./scripts/player_behavior.gd:func player_block() -> void: # Called by state_machine(); Localized magic wall for defense #TODO: Make the block magic bigger.

implement saves (needs ball too), touches (player), ranged attacks (player), melee (player), blocks (player), platforms (player)

# Ball
./scripts/ball.gd:#TODO : what happens when we're on fire? Force multiplier??
./scripts/ball.gd:func write_gitgud_message() -> void: #TODO these are for saves/missed shots

# Global
./scripts/global.gd:#TODO global.process() Get their stats: Goals, kills, murders (total deaths - own goals), shots, own goals
./scripts/global.gd:#TODO player_behavior() also implement saves, touches, ranged, melee, blocks, platforms && global.process() Then get those stats
./scripts/global.gd:#TODO we'll cross-analyze these stats in the stats screen, for player % intercomparison; "Player4 had 77% of touches!"
./scripts/global.gd:#TODO among those cross-analyzed stats, pick the 4 largest numbers, display those.
