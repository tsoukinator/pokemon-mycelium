#===============================================================================
# Adds/edits various Summary utilities.
#===============================================================================
=begin
class PokemonSummary_Scene
  def drawPageINNATES
    overlay = @sprites["overlay"].bitmap
    base_color = Color.new(248, 248, 248)
    shadow_color = Color.new(104, 104, 104)
    text_base_color = Color.new(64, 64, 64)
    text_shadow_color = Color.new(176, 176, 176)
	text_red_color  = Color.new(175, 34, 34)
	text_red_shadow = Color.new(247, 106, 106)
    # Determine which stats are boosted and lowered by the Pokémon's nature
    statshadows = {}
    GameData::Stat.each_main { |s| statshadows[s.id] = shadow_color }
    # Write various bits of text
    textpos = [
      [_INTL(" Innate 1"), 224, 80, :left, base_color, shadow_color],
	  [_INTL(" Innate 2"), 224, 180, :left, base_color, shadow_color],
	  [_INTL(" Innate 3"), 224, 280, :left, base_color, shadow_color]
    ]
	 # Get variables for the progress system
	small_font = Settings::SMALL_FONT_IN_SUMMARY
    use_variable_unlock = Settings::INNATE_PROGRESS_WITH_VARIABLE
	use_level_unlock = Settings::INNATE_PROGRESS_WITH_LEVEL
	levels_to_unlock = Settings::LEVELS_TO_UNLOCK.find { |entry| entry.first == @pokemon.species }&.drop(1) || Settings::LEVELS_TO_UNLOCK.last #Added check for the specific ID of a pokemon.
	display_count = $game_variables[Settings::INNATE_PROGRESS_VARIABLE]
	pokemon_level = @pokemon.level
	
	# Draw innate name and description
	# Iterate over each innate skill
    3.times do |i|
      innate_name = @pokemon.getInnateListName[i]
      innate_data = GameData::Innate.try_get(innate_name)
	  
	   # If the pokemon doesn't have an Innate to show
      innate_name_display = innate_data ? innate_data.name : "---"
      innate_desc_display = innate_data ? innate_data.description : "--- No innate ---"

	#Properly write down each part of the innate
	if innate_data
        if use_level_unlock && pokemon_level < levels_to_unlock[i]
          textpos << ["Locked", 362, 80 + i * 100, :left, text_red_color, text_red_shadow]
          if small_font
            pbSetSmallFont(overlay)
            drawFormattedTextEx(overlay, 224, 112 + i * 100, 282, "This pokemon's innate is currently locked until level #{levels_to_unlock[i]}.", text_red_color, text_red_shadow, 20)
            pbSetSystemFont(overlay)
          else
            drawTextEx(overlay, 224, 112 + i * 100, 282, 2, "This innate is currently locked until level #{levels_to_unlock[i]}.", text_red_color, text_red_shadow)
          end
        elsif use_variable_unlock && i >= display_count
          textpos << ["Locked", 362, 80 + i * 100, :left, text_red_color, text_red_shadow]
          if small_font
            pbSetSmallFont(overlay)
            drawFormattedTextEx(overlay, 224, 112 + i * 100, 282, "This pokemon's innate is currently locked.", text_red_color, text_red_shadow, 20)
            pbSetSystemFont(overlay)
          else
            drawTextEx(overlay, 224, 112 + i * 100, 282, 2, "This innate is currently locked.", text_red_color, text_red_shadow)
          end
        else
          textpos << [innate_data.name, 362, 80 + i * 100, :left, text_base_color, text_shadow_color]
          if small_font
            pbSetSmallFont(overlay)
            drawFormattedTextEx(overlay, 224, 112 + i * 100, 282, innate_data.description, text_base_color, text_shadow_color, 20)
            pbSetSystemFont(overlay)
          else
            drawTextEx(overlay, 224, 112 + i * 100, 282, 2, innate_data.description, text_base_color, text_shadow_color)
          end
        end
	  else #The Pokemon has no Innate to show
	  textpos << [innate_name_display, 362, 80 + i * 100, :left, text_base_color, text_shadow_color]
        if small_font
          pbSetSmallFont(overlay)
          drawFormattedTextEx(overlay, 224, 112 + i * 100, 282, innate_desc_display, text_base_color, text_shadow_color, 20)
          pbSetSystemFont(overlay)
        else
          drawTextEx(overlay, 224, 112 + i * 100, 282, 2, innate_desc_display, text_base_color, text_shadow_color)
        end
      end
    end #
    
    pbDrawTextPositions(overlay, textpos)
  end
end
=end
class PokemonSummary_Scene
  def drawPageINNATES
    overlay = @sprites["overlay"].bitmap
    base_color = Color.new(248, 248, 248)
    shadow_color = Color.new(104, 104, 104)
    text_base_color = Color.new(64, 64, 64)
    text_shadow_color = Color.new(176, 176, 176)
    text_red_color = Color.new(175, 34, 34)
    text_red_shadow = Color.new(247, 106, 106)
    small_font = Settings::SMALL_FONT_IN_SUMMARY
    use_variable_unlock = Settings::INNATE_PROGRESS_WITH_VARIABLE
    use_level_unlock = Settings::INNATE_PROGRESS_WITH_LEVEL
    levels_to_unlock = Settings::LEVELS_TO_UNLOCK.find { |entry| entry.first == @pokemon.species }&.drop(1) || Settings::LEVELS_TO_UNLOCK.last
    display_count = $game_variables[Settings::INNATE_PROGRESS_VARIABLE]
    pokemon_level = @pokemon.level

    # Load all innate abilities into "Available Innates"
    #available_innates = @pokemon.getInnateList.map(&:first)

    # Check if this Pokémon already has fixed innate abilities
    #if !@pokemon.instance_variable_defined?(:@fixed_innates) || @pokemon.instance_variable_get(:@fixed_innates).nil?
      #active_innates = []

      # Check if INNATE_RANDOMIZER is enabled
      #if Settings::INNATE_RANDOMIZER
      #  max_amount = Settings::INNATE_MAX_AMOUNT
      #  active_innates = available_innates.sample([max_amount, available_innates.size].min)
     # else
     #   active_innates = available_innates
     # end

      # Store the fixed innates with the Pokémon
    #  @pokemon.instance_variable_set(:@fixed_innates, active_innates)
    #else
      # Use the fixed innates if they already exist
    #  active_innates = @pokemon.instance_variable_get(:@fixed_innates)
    #end
	
	#@pokemon.instance_variable_set(:@active_innates, active_innates)
	if !@pokemon.instance_variable_defined?(:@fixed_innates) || @pokemon.instance_variable_get(:@fixed_innates).nil?
		if Settings::INNATE_RANDOMIZER
			max_amount = Settings::INNATE_MAX_AMOUNT
			@pokemon.select_random_innates(max_amount, @pokemon.ability_id)
		else
			# If randomizer is not enabled, use all available innates
			@pokemon.instance_variable_set(:@active_innates, @pokemon.getInnateList.map(&:first).uniq)
			@pokemon.instance_variable_set(:@fixed_innates, @pokemon.instance_variable_get(:@active_innates))
		end
	else
		# Use the fixed innates if they already exist
		@pokemon.instance_variable_set(:@active_innates, @pokemon.instance_variable_get(:@fixed_innates))
	end
    # Draw innate name and description
    #textpos = [
    #  [_INTL(" Star Sign"), 224, 80, :left, base_color, shadow_color],
    #  [_INTL(" Innate 2"), 224, 180, :left, base_color, shadow_color],
    #  [_INTL(" Innate 3"), 224, 280, :left, base_color, shadow_color]
    #]

    textpos = [
      [_INTL(" Star Sign"), 224, 80, :left, base_color, shadow_color]
    ]
    
    # Iterate over each innate skill
    3.times do |i|
      innate_name = @pokemon.instance_variable_get(:@active_innates)[i]#innate_name = active_innates[i]
      innate_data = GameData::Innate.try_get(innate_name)
	  
	  # If the pokemon doesn't have an Innate to show
      innate_name_display = innate_data ? innate_data.name : "---"
      innate_desc_display = innate_data ? innate_data.description : "--- No innate ---"

      if innate_data
        if use_level_unlock && pokemon_level < levels_to_unlock[i]
          textpos << ["Locked", 362, 80 + i * 100, :left, text_red_color, text_red_shadow]
          if small_font
            pbSetSmallFont(overlay)
            drawFormattedTextEx(overlay, 224, 112 + i * 100, 282, "This pokemon's innate is currently locked until level #{levels_to_unlock[i]}.", text_red_color, text_red_shadow, 20)
            pbSetSystemFont(overlay)
          else
            drawTextEx(overlay, 224, 112 + i * 100, 282, 2, "This innate is currently locked until level #{levels_to_unlock[i]}.", text_red_color, text_red_shadow)
          end
        elsif use_variable_unlock && i >= display_count
          textpos << ["Locked", 362, 80 + i * 100, :left, text_red_color, text_red_shadow]
          if small_font
            pbSetSmallFont(overlay)
            drawFormattedTextEx(overlay, 224, 112 + i * 100, 282, "This pokemon's innate is currently locked.", text_red_color, text_red_shadow, 20)
            pbSetSystemFont(overlay)
          else
            drawTextEx(overlay, 224, 112 + i * 100, 282, 2, "This innate is currently locked.", text_red_color, text_red_shadow)
          end
        else
          textpos << [innate_data.name, 362, 80 + i * 100, :left, text_base_color, text_shadow_color]
          if small_font
            pbSetSmallFont(overlay)
            drawFormattedTextEx(overlay, 224, 112 + i * 100, 282, innate_data.description, text_base_color, text_shadow_color, 20)
            pbSetSystemFont(overlay)
          else
            drawTextEx(overlay, 224, 112 + i * 100, 282, 2, innate_data.description, text_base_color, text_shadow_color)
          end
        end
      else
        textpos << [innate_name_display, 362, 80 + i * 100, :left, text_base_color, text_shadow_color]
        if small_font
          pbSetSmallFont(overlay)
          drawFormattedTextEx(overlay, 224, 112 + i * 100, 282, innate_desc_display, text_base_color, text_shadow_color, 20)
          pbSetSystemFont(overlay)
        else
          drawTextEx(overlay, 224, 112 + i * 100, 282, 2, innate_desc_display, text_base_color, text_shadow_color)
        end
      end
    end

    pbDrawTextPositions(overlay, textpos)
  end
end
