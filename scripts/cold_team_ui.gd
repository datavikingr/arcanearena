extends TeamUI

func score(_player_name) -> void:
	goals += 1
	if goals >= 20:
		cold_team_wins()
