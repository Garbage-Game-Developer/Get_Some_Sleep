extends Control


func _on_animation_player_animation_finished(anim_name):
	Global.game_controller.splash_screen_end()
	queue_free()
