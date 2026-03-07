extends Node

#combat
signal attack_landed(attacker, target, attack_data)
signal damage_taken(target, attack_data)
signal entity_died(entity)

#player
signal player_jumped(player)

#items
signal coin_collected(player)
