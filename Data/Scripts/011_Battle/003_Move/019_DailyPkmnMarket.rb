
DAILY_PKMN_MARKET = 224 # Adjust this ID as needed

def pbDailyPkmnMarket
  # Step 1: Get the current day of the week (0 = Sunday, 6 = Saturday)
  #day_of_week = Time.now.wday

  # Step 2: Calculate the remainder when the day of the week is divided by 3
  #remainder = day_of_week % 3
  #puts remainder
  
  # Retrieve the last used date from the game variable
  last_used_date = $game_variables[DAILY_PKMN_MARKET]
  
  pbMessage(_INTL("Hey there, welcome to the daily market."))
  #puts DAILY_PKMN_MARKET
  
  puts Time.now.strftime("%Y-%m-%d")
  puts last_used_date
  
  #unless Time.now.strftime("%Y-%m-%d") != last_used_date
  #  pbMessage(_INTL("Hang on, you can only trade once every 24 hours."))
  #  pbMessage(_INTL("Try again tomorrow."))
  #  return
  #end
  
  ###################################
  #### Calculating - Day of Year ####
  ###################################
  # Step 1: Get the current date
  current_time = Time.now
  current_day = current_time.day
  current_month = current_time.month
  current_year = current_time.year
  
  # Step 2: Define days in each month and handle leap years
  def leap_year?(year)
    (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
  end
  
  days_in_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  days_in_month[1] = 29 if leap_year?(current_year)
  
  # Step 3: Calculate the day of the year
  day_of_year = days_in_month.take(current_month - 1).sum + current_day
  
  # Step 4: Calculate the remainder when divided by 3
  remainder = day_of_year % 3
  
  ##################################################
  ########## Defining Pokemon for Trade ############
  ##################################################
  # Define Pokémon sets (using internal IDs of Pokémon)
  set_a_pokemon = [:PIKACHU, :BULBASAUR, :CHARMANDER]
  set_b_pokemon = [:SQUIRTLE, :JIGGLYPUFF, :MEOWTH]
  set_c_pokemon = [:EEVEE, :SNORLAX, :MAGIKARP]
  
  # Daily trade sets (corresponding to the Pokémon sets)
  daily_trade_setlist = { "Set A" => set_a_pokemon, "Set B" => set_b_pokemon, "Set C" => set_c_pokemon }
  
  # Randomly select today's set
  #today_set_name = daily_trade_setlist.keys.sample
  #today_pokemon_set = daily_trade_setlist[today_set_name]
  
  today_set_name = daily_trade_setlist.keys[remainder]
  today_pokemon_set = daily_trade_setlist[today_set_name]
  
  # Display the set and Pokémon list
  pokemon_list = today_pokemon_set.map { |poke| (poke.to_s) }.join(", ")
  pbMessage(_INTL("Today's random selection is {1}. The Pokémon available are: {2}", today_set_name, pokemon_list))
  
  # Allow the player to choose a Pokémon
  pokemon_choices = today_pokemon_set.map { |poke| (poke.to_s) }
  #chosen_index = pbShowCommands(nil, pokemon_choices, -1)
  chosen_index = pbMessage(_INTL("Select your Pokemon."), pokemon_choices, -1) # -1 allows Cancel option
    
  if chosen_index >= 0
    # Allow trainer to choose pokemon to trade for
    pbChoosePokemon(1,3)
    
    player_pkmn = $player.party[pbGet(1)]
    
    chosen_pokemon = today_pokemon_set[chosen_index]
    poke = Pokemon.new(chosen_pokemon, player_pkmn.level)
    
    #### Get Value of Pokemon Listed on Market
    ## Set level according to badges player owns
    ## Set price using our price tool from the broker
    
    
    #######
    
    nick = ""
    ot = "Tsoukinator"
    otGender = 0
  
    pbStartTrade(pbGet(1), poke, nick, ot, otGender)
    $game_variables[DAILY_RANDOM_TRADE] = Time.now.strftime("%Y-%m-%d")
    pbMessage(_INTL("You selected {1}!", chosen_pokemon.to_s))
    # Perform an action with the selected Pokémon (e.g., add to party, trade, etc.)
  end

end