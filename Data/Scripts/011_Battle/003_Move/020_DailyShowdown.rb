
# Define the game variable ID for storing the last battle date
LAST_BATTLE_DATE_VAR_ID = 222 # Adjust this ID as needed

def initialize_battle_date_variable
  # Ensure the variable exists and is set to the default date if needed
  if !$game_variables[LAST_BATTLE_DATE_VAR_ID].is_a?(String)
    $game_variables[LAST_BATTLE_DATE_VAR_ID] = "2020-01-01"
  end
end

def can_battle_today?
  # Ensure the game variable is initialized
  initialize_battle_date_variable
  
  # Retrieve the last recorded battle date
  last_battle_date_str = $game_variables[LAST_BATTLE_DATE_VAR_ID]

  # Get today's date in the format "YYYY-MM-DD"
  current_date_str = Time.now.strftime("%Y-%m-%d")

  # Compare the last battle date with the current date
  return current_date_str != last_battle_date_str # Returns true if it's a different day, false if it's the same day
end

def record_battle
  # Record the current date as the last battle date
  $game_variables[LAST_BATTLE_DATE_VAR_ID] = Time.now.strftime("%Y-%m-%d")
end

def choose_showdown_set
  people_set = [
    [:FOODBABY, "FoodBaby"],
    [:TSOUKINATOR, "Tsoukinator"],
    [:UHRLEX, "Uhrlex"],
    [:BROTHER, "Brother"],
    [:ANNA, "Anna"],
    [:JAWLINE, "Jawline"],
    [:THESHARK, "The Shark"],
    [:HAYDOS, "Haydos"],
    [:JJ, "JJ"],
    [:CARLEY, "Carley"],
    [:ANN, "Ann"],
    [:ANDREW, "Andrew"]
  ]

  pet_set = [
    [:BABYRAGNAR, "Ragnar"],
    [:BABYELSA, "Elsa"],
    [:BABYEDGAR, "Edgar"],
    [:BABYFEN, "Fen"],
    [:BABYVUCKO, "Vucko"]
  ]
  
  starter_set = [
    [:BULBASAUR, "Bulbasaur"],
    [:CHARMANDER, "Charmander"],
    [:SQUIRTLE, "Squirtle"]
  ]
  
  sets = [
    ["People", people_set],
    ["Pets", pet_set]
  ]
  
  # Present the choice between the two sets
  set_names = sets.map { |set| _INTL(set[0]) }
  # Add an "Exit" option at the end
  set_names.push(_INTL("Exit"))
  
  loop do
    selected_set = pbMessage(_INTL("Select people, or pets."), set_names, -1) # -1 allows Cancel option
    
    # Handle if the player presses the Cancel button (typically mapped to B or Esc)
    if selected_set < 0
      return nil
    end

    # If the player chooses "Exit", return nil to indicate cancellation
    return nil if selected_set == set_names.length - 1
  
    return sets[selected_set][1] # Return the selected set array
  end
end

def choose_showdown
  selected_set = choose_showdown_set
  # If the player chose to exit, stop the process
  return if selected_set.nil?
  
  # Extract the display names for the selected set
  commands = selected_set.map { |choice| _INTL(choice[1]) }
  commands.push(_INTL("Exit"))
  
  loop do
    # Show the choices to the player
    choice = pbMessage(_INTL("Choose your showdown!"), commands, -1) # -1 allows Cancel option

    # Handle if the player presses the Cancel button (typically mapped to B or Esc)
    if choice < 0
      return nil
    end

    # If the player chooses "Exit", return nil to indicate cancellation
    return nil if choice == commands.length - 1
  
    return selected_set[choice][0] # Return the selected Pokémon
  end
end

def get_highest_level_in_party
  # Get the player's party
  party = $player.party
  
  # Find the highest level Pokémon in the party
  highest_level = party.map { |pokemon| pokemon.level }.max
  
  # Set adaptation of level to be 70% of max level
  wild_level = ((highest_level * 0.7).to_i).round(0)
  
  # Ensure wild Pokémon level is at least 5
  wild_level = [wild_level, 5].max
  
  return wild_level
end

def start_showdown
  pbMessage(_INTL("Hey there, looks like it's time for your daily showdown."))

  unless can_battle_today?
    pbMessage(_INTL("Hang on, you can only start a showdown once every 24 hours."))
    pbMessage(_INTL("Try again tomorrow."))
    return
  end
  
  pbMessage(_INTL("Hope you've stocked up on some Pokeballs."))

  selected_pokemon = choose_showdown
  
  # If the player chose to exit, stop the process
  return if selected_pokemon.nil?
  
  # Get the highest level Pokémon in the player's party
  wild_pokemon_level = get_highest_level_in_party
  
  # Create the Pokémon for the battle
  #battler = Pokemon.new(selected_pokemon, wild_pokemon_level) # Level 5 starter Pokémon

  ##
  loop do
    selection = pbMessage(_INTL("Remember, you can only do this once per day. Are you ready?"), ["Yes","No"], -1) # -1 allows Cancel option
    puts selection
    # Handle if the player presses the Cancel button (typically mapped to B or Esc)
    if selection != 0
      return nil
    end
    break
  end
  
  # Record the battle to ensure the player cannot battle again today
  record_battle
  
  # Start the battle with the selected Pokémon
  #WildBattle.start(selected_pokemon, 5) # 5 is the level of the wild Pokémon
  setBattleRule("cannotRun")
  battle = WildBattle.start(selected_pokemon, wild_pokemon_level) # 5 is the level of the wild Pokémon
  
  # Ensure the player cannot run from the battle
  #battle.scene = pbBattleScene
  #battle.pbBattle
end
