def give_random_pokemon(level = 5)
  # Define an array containing the names of the Pokemon
  pokemon_list = [:TSOUKINATOR, :FOODBABY, :JAWLINE, :JJ, :UHRLEX, :XERRI, :BROTHER, :THESHARK]

  # Generate a random number between 0 and the number of Pokemon in the list minus 1
  random_index = rand(pokemon_list.size)

  # Get the Pokemon species name corresponding to the random index
  random_pokemon = pokemon_list[random_index]

  # Add the random Pokemon to the player's party at level 5 (adjust the level as needed)
  pbAddPokemonSilent(random_pokemon, level)
end

####################333
################################################
### BATTLE ARENA CODE #########################
################################################

def set_battle_rules(rules)
  rules.each do |rule|
    if rule.is_a?(String)
      setBattleRule(rule)
    elsif rule.is_a?(Array)
      setBattleRule(*rule)
    end
  end
end

####
#
#moss_species = [:PARAS_1, :PARASECT_1, :SHROOMISH_1, :BRELOOM_1]  # Add more species as needed

def belongs_to_species_list?(pokemon, list)
  return list.include?(pokemon.species)
end