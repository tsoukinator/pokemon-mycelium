def getActiveInnates(pkmn)
  pkmn.instance_variable_get(:@active_innates) || []
end

MenuHandlers.add(:pokemon_debug_menu, :set_innates, {
  "name"   => _INTL("Set Innates"),
  "parent" => :main,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    cmd = 0
    commands = [
      _INTL("This option is broken. Don't use."),
      _INTL("Randomize Defined Innates"),
      _INTL("Reset Innates")
    ]
    loop do
      innates = getActiveInnates(pkmn)
      msg = _INTL("Innates are: {1}", innates.join(", "))
      cmd = screen.pbShowCommands(msg, commands, cmd)
      break if cmd < 0
      case cmd
      when 0   # Set Innate Abilities
    params = ChooseNumberParams.new
    params.setRange(1, GameData::Ability.count)
    params.setDefaultValue(1)
    max_innates = screen.pbMessageChooseNumber(_INTL("BROKEN (For now)! DO NOT USE! "), params)
    
    chosen_innates = []
    max_innates.times do |i|
        new_innate = pbChooseAbilityList(chosen_innates)
        puts "Chosen innate: #{new_innate.inspect}" # Debugging line
        if new_innate.nil?
            puts "No innate was chosen, exiting loop." # Debugging line
            break
        end
        chosen_innates << new_innate
        puts "Chosen innates so far: #{chosen_innates.inspect}" # Debugging line
    end
    pkmn.instance_variable_set(:@active_innates, chosen_innates)
    pkmn.instance_variable_set(:@fixed_innates, chosen_innates)
    puts "@active_innates set to: #{pkmn.instance_variable_get(:@active_innates).inspect}" # Debugging line
    screen.pbRefreshSingle(pkmnid)
      when 1   # Randomize Defined Innates
		available_innates = pkmn.getInnateList.map(&:first).uniq
		primary_ability_id = pkmn.ability_id

		# Exclude the primary ability from available innates
		available_innates.delete(primary_ability_id) if primary_ability_id

		params = ChooseNumberParams.new
		params.setRange(1, available_innates.size)
		params.setDefaultValue(1)
		max_innates = screen.pbMessageChooseNumber(_INTL("How many innates should this Pokémon have?"), params)
  
		# Ensure max_innates does not exceed available innates
		max_innates = [max_innates, available_innates.size].min

		# Use the select_random_innates method to set the random innates
		pkmn.select_random_innates(max_innates, primary_ability_id)

		# Refresh the display for the single Pokémon
		screen.pbRefreshSingle(pkmnid)
	when 2   # Reset Innates
        available_innates = pkmn.getInnateList.map(&:first)
        params = ChooseNumberParams.new
        params.setRange(1, available_innates.size)
        params.setDefaultValue(1)
        max_innates = screen.pbMessageChooseNumber(_INTL("How many innates should this Pokémon have?"), params)
        
        pkmn.instance_variable_set(:@active_innates, available_innates.take(max_innates))
        pkmn.instance_variable_set(:@fixed_innates, pkmn.instance_variable_get(:@active_innates))
        screen.pbRefreshSingle(pkmnid)
      end
    end
    next false
  }
})