extends Node

#combat
signal attack_landed(attacker, target, attack_data)
signal damage_taken(target, attack_data)
signal entity_died(entity)

#player
signal player_jumped(player)
signal player_slammed(player)
signal player_hurt(player)
signal player_fell(player)
signal player_health_changed(current_health)
signal player_died()

#items/ui
signal coin_collected(player)
signal coin_amount_changed(amount)
signal game_reset()
signal wall_switch_activated()
