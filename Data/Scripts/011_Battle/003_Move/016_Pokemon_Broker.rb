################################################################################
# Pokemon Broker
################################################################################

def pbChooseAblePokemonByType(variableNumber, nameVarNumber, type = nil)
  pbChoosePokemon(variableNumber, nameVarNumber, proc { |pkmn|
    next false if pkmn.egg?
    next true if type.nil?  # Allow all Pokémon if type is not specified
    next pkmn.hasType?(type)
  })
end

def sellPokemonToNPC(pokemon_type = nil)
  if pokemon_type.nil?
    broker_text = "I'm looking to buy a Pokemon. I'll give you good money for it!"
  else
    broker_text = "I'm looking to buy a #{pokemon_type} Pokemon. I'll give you good money for it!"
  end
  Kernel.pbMessage(_INTL("#{broker_text}"))
  
  if $player.able_pokemon_count <= 1
    Kernel.pbMessage(_INTL("Hey, you can't sell your last Pokemon!"))
    #break
  else
    
  eligible_pokemon = $player.party.select do |pkmn|
    if pokemon_type
      pkmn.hasType?(pokemon_type)
    else
      true
    end
  end

  if eligible_pokemon.empty?
    Kernel.pbMessage(_INTL("You have no Pokémon that can be sold."))
    return
  end

  pbChooseAblePokemonByType(1, 3, pokemon_type)
  chosen_index = pbGet(1)

  if chosen_index == -1
    return
  end

  chosen_pokemon = $player.pokemon_party[chosen_index]
  
  total_stats = chosen_pokemon.baseStats[:HP] +
                chosen_pokemon.baseStats[:ATTACK] +
                chosen_pokemon.baseStats[:DEFENSE] +
                chosen_pokemon.baseStats[:SPECIAL_ATTACK] +
                chosen_pokemon.baseStats[:SPECIAL_DEFENSE] +
                chosen_pokemon.baseStats[:SPEED]
  
  species_data = GameData::Species.get(chosen_pokemon.species)
  catch_rate = species_data.catch_rate

  #base_price = total_stats - (catch_rate * 1) + (chosen_pokemon.level * 2)
  base_price = [(total_stats - (catch_rate * 1)),0].max + (chosen_pokemon.level * 2)
  puts base_price
  ######
  # Define a function to map the proportion to a multiplier between 1 and 3 using a centered exponential curve
  def iv_multiplier(iv_total)
    iv_proportion = iv_total.to_f / 186.to_f
    min_multiplier = 1
    max_multiplier = 3
    center_multiplier = 2
    # Exponential scaling factor to control the curve
    scaling_factor = 5
    # Adjust the exponent to center the midpoint
    exponent = 2 * iv_proportion - 1  # Center the growth around the midpoint
    # Calculate multiplier
    multiplier = min_multiplier + (max_multiplier - min_multiplier) * (1 / (1 + Math.exp(-scaling_factor * exponent)))
    return ([min_multiplier, [multiplier, max_multiplier].min].max).round(3) # Ensure multiplier is within the range
  end
    # Calculate total IV bonus
    iv_total = chosen_pokemon.iv[:HP] +
               chosen_pokemon.iv[:ATTACK] +
               chosen_pokemon.iv[:DEFENSE] +
               chosen_pokemon.iv[:SPECIAL_ATTACK] +
               chosen_pokemon.iv[:SPECIAL_DEFENSE] +
               chosen_pokemon.iv[:SPEED]
    
    puts "IV TOTAL"
    puts iv_total
    # Calculate the multiplier based on IV proportion
    multiplier = iv_multiplier(iv_total)
    
    # Apply the multiplier to the base price
    base_price = (base_price * multiplier).round(0)
                   
    #base_price = base_price + iv_bonus
    puts multiplier
    puts base_price
    #base_price = base_price + normalized_bonus  
    
    #base_price = [base_price,200].min
    
  ######
  multiplier = 1

  base_price *= 2 if chosen_pokemon.shiny?
  #base_price *= 2 if chosen_pokemon.ot == "Alpha"

  pokeball_price = (GameData::Item.get(species_data.egg_groups[0].to_sym).price rescue 0)
  if pokeball_price > 0
    base_price += pokeball_price
  end

  base_price += ((GameData::Item.get(chosen_pokemon.item).price rescue 0) / 2) if chosen_pokemon.item
  base_price = base_price * (1 + (chosen_pokemon.level.to_f/150)).round(2)
  base_price = [base_price.round(-1),200].max # Round to nearest 10, get max
  
  
  if Kernel.pbConfirmMessage(_INTL("Would you like to sell your {1} for ${2}?", chosen_pokemon.name, base_price))
    $player.remove_pokemon_at_index(chosen_index)
    $player.money += base_price
    Kernel.pbMessage(_INTL("You sold your {1} for ${2}.", chosen_pokemon.name, base_price))
  else
    Kernel.pbMessage("Player declined the sale.")
  end
end

end

# Script Command:
# sellPokemonToNPC - Will allow selling of any type.
# sellPokemonToNPC(:WATER) - Will allow selling only Water-type Pokémon.
# sellPokemonToNPC(:FIRE) - Will allow selling only FIRE-type Pokémon.

#Event Setup:
#Event Condition to prevent the last pokemon in the party from being sold should
#be $Trainer.ablePokemonCount==1 used in a condtional branch and the script commands
#placed in the else portion of the same condtional branch.