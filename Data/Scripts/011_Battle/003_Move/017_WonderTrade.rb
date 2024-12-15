#===============================================================================
# Wonder Trade Script by Sploopo
#===============================================================================
# This script creates a Wonder Trade-like system, where the player sends away
# one of their Pokémon and recieves a random one in return.
# Rather than randomly generating Pokémon, this script allows you to create
# Pokémon beforehand which will be traded to the user.
# All Pokémon are also part of a certain rarity, meaning some Pokémon will be
# more commonly recieved than others.
#===============================================================================
# You can use this script by calling pbWonderTrade in place of a normal trade.
# For information on how to create a normal trade, check the wiki.
#===============================================================================
# For this script to work, put it above main.
# Please give credit to Sploopo when using this.
#===============================================================================

COMMON_CHANCE = 45 # The chance for a random "Common" Pokémon to be selected.
UNCOMMON_CHANCE = 25 # Same as above, but with "Uncommon".
RARE_CHANCE = 15 # You get the idea.
SUPERRARE_CHANCE = 10
EPIC_CHANCE = 4
SUPEREPIC_CHANCE = 1
# Ensure that all of these "chance" values add up to 100, or things might break.

def pbWonderTrade
  tradedMon = rand(100) + 1 # Do not edit this line!
 
  if(tradedMon <= COMMON_CHANCE) # Common selected
    choose = rand(3) + 1 # Change the "3" on this line to however many Pokémon you
    # want in this rarity level.
 
    case choose
    when 1 # A simple Pokémon to be traded to the player.
      poke = Pokemon.new(:BULBASAUR, 10) # A Lv. 10 Bulbasaur...
      nick = "Example" # ... with the nickname "Example"...
      ot = "R. Nixon" # ... with the original trainer "R. Nixon"...
      otGender = 0 # ... whose gender is male.
      # Because there are 3 Pokémon in this rarity, if the Common rarity is
      # chosen by the script, this has a 1/3 chance of being traded to the player.
    when 2 # Another simple Pokémon.
      poke = Pokemon.new(:CHARMANDER, 10)
      nick = "Example"
      ot = "Example"
      otGender = 1 # This original trainer is female.
    when 3 # Another one.
      poke = Pokemon.new(:SQUIRTLE, 10)
      nick = "\"The Rock\" Jh"
      ot = "Dwayne"
      otGender = 0
    end
    # Check the wiki for information on how to modify a Pokémon further.

  elsif(tradedMon <= UNCOMMON_CHANCE + COMMON_CHANCE) # Uncommon selected
    # All rarities need at least 1 Pokémon in them, or else the script will break.
    # I've put in some dummy ones.
    poke = Pokemon.new(:EDGARMON, 10)
    nick = "Gaga"
    ot = "FoodBaby"
    otGender = 1
  elsif(tradedMon <= RARE_CHANCE + UNCOMMON_CHANCE + COMMON_CHANCE) # Rare selected
    poke = Pokemon.new(:VULPIX, 10)
    nick = "Ember"
    ot = "Cindy"
    otGender = 0
  elsif(tradedMon <= SUPERRARE_CHANCE + RARE_CHANCE + UNCOMMON_CHANCE + COMMON_CHANCE) # Super Rare selected
    poke = Pokemon.new(:BEEDRILL, 10)
    nick = "Bug Catcher"
    ot = "Darren"
    otGender = 0
  elsif(tradedMon <= EPIC_CHANCE + SUPERRARE_CHANCE + RARE_CHANCE + UNCOMMON_CHANCE + COMMON_CHANCE) # Epic selected
    poke = Pokemon.new(:RAGNARMON, 10)
    nick = "Jim"
    ot = "Jim"
    otGender = 0
  else # Super Epic selected
    poke = Pokemon.new(:RESHIRAM, 69)
    nick = "Reshiram"
    ot = "JustinRPG"
    otGender = 0
  end
 
  pbChoosePokemon(1,3)
  pbStartTrade(pbGet(1), poke, nick, ot, otGender) # The trade.
end

#===============================================================================