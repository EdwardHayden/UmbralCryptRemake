extends Interactable
class_name Door

enum state {OPEN_A, OPEN_B, CLOSED}
var current_state = state.CLOSED

var locked : bool = false

func on_interact(player_id : int):
	var player : PlayerInfo = PlayerManager.players[player_id]
	if $AnimationPlayer.is_playing():
		return
	if locked:
		pass # Play locked SFX
	else:
		match current_state:
			state.CLOSED:
				# if player is that side:
				if $StaticBody3D.to_local(player.position).x > 0:
					$AnimationPlayer.play("openDoor_A")
					current_state = state.OPEN_A
				else:
					$AnimationPlayer.play("openDoor_B")
					current_state = state.OPEN_B
			state.OPEN_A:
				$AnimationPlayer.play("closeDoor_A")
				current_state = state.CLOSED
			state.OPEN_B:
				$AnimationPlayer.play("closeDoor_B")
				current_state = state.CLOSED
			
