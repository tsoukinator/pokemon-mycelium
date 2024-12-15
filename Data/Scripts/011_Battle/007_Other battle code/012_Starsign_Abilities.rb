#######
###
zodiac_signs = [
  "Aries", "Taurus", "Gemini", "Cancer", 
  "Leo", "Virgo", "Libra", "Scorpio", 
  "Sagittarius", "Capricorn", "Aquarius", "Pisces"
]

moon_phases = [
"New Moon","Waxing Crescent","First Quarter","Waxing Gibbous","Full Moon","Waning Gibbous","Last Quarter","Waning Crescent"
]

current_time = pbGetTimeNow()
#Time.new(2024, 8, 10)
#zodiac(pbGetTimeNow().mon, pbGetTimeNow().day)
# Extract the current month and day
current_month = current_time.mon
current_day = current_time.day

# Get the current Zodiac sign index (number)
current_zodiac_index = zodiac(current_month, current_day)

# Get the name of the Zodiac sign
#current_zodiac_sign = zodiac_signs[current_zodiac_index]
current_zodiac_sign = moon_zodiac_sign(pbGetTimeNow())

# Get the current moon phase index (number)
current_moon_index = moonphase(pbGetTimeNow())
# Get current moon phase (name)
current_moon_phase = moon_phases[moonphase(pbGetTimeNow())]
current_moon_day = moonphase_day(pbGetTimeNow()-1)
#current_moon_day = 27

def announce_moon_sign(battler, battle, zodiac, moon_day, moon_phase, ability)
  puts "Current Zodiac sign is: #{zodiac}"
  puts "Current Moon Day is: #{moon_day}"
  puts "Current Moon Phase is: #{moon_phase}"
  #battle.pbDisplay(_INTL("#{zodiac} is the current moon sign! \nCurrent Moon phase is: {2}", battler.pbThis, moon_phase))
  
  moon_day = moon_day - 1 # Ensure moon day corresponds to array index (0=day 1)
  
  # If moon day is not a day where Critical Hits or Immunity is concerned
  # Apply the stat boosts here (otherwise, apply in handlers lower in page)
  if ![8, 18, 27, 7, 14, 22, -1].include?(moon_day)
    bonus_frame = [:SPEED, :ATTACK, :SPECIAL_ATTACK, :EVASION, :ACCURACY, :DEFENSE, :SPECIAL_DEFENSE, :HP, :HP, :SPEED, :EVASION, :ACCURACY, :DEFENSE, :SPECIAL_DEFENSE, :HP, :SPECIAL_ATTACK, :ATTACK, :SPEED, :HP, :EVASION, :DEFENSE, :SPECIAL_DEFENSE, :HP, :ACCURACY, :SPECIAL_ATTACK, :ATTACK, :EVASION, :HP]
    raise_stat = bonus_frame[moon_day]
    puts "Raise Stat for #{battler}: #{raise_stat}"
    battler.pbRaiseStatStageSilent(raise_stat, 1, battler, showAnim = false, ignoreContrary = true)
    #battler.pbRaiseStatStage(raise_stat, 1, battler, showAnim = true, ignoreContrary = true)
  end
end

def moon_sign(battler, battle, zodiac)
    battle.pbShowAbilitySplash(battler)
    #puts "Current Zodiac sign is: #{zodiac}"
    battle.pbDisplay(_INTL("#{zodiac} is the current moon sign! \n{1}'s stats rose!", battler.pbThis))
    
    [:ATTACK, :DEFENSE, :SPECIAL_ATTACK, :SPECIAL_DEFENSE, :SPEED, :ACCURACY].each do |stat|
      battler.pbRaiseStatStageSilent(stat, 1, battler, showAnim = false, ignoreContrary = true)
    end
  battle.pbCommonAnimation("StatUp", battler) #StatUp, FocusPunch, BeakBlast, ShellTrap
  battle.pbHideAbilitySplash(battler)

end

  # Output the result
  #puts "Today month is: #{current_month}"
  #puts "Today day is: #{current_day}"
  #puts "Current Zodiac sign is: #{current_zodiac_sign}"
  
# Correct method calls with parentheses
  #puts "Opposite Zodiac sign is: #{zodiac_signs[zodiacOpposite(current_zodiac_index)]}"
  #puts "Partner Zodiac sign(s) are: #{zodiacPartners(current_zodiac_index).map { |index| zodiac_signs[index] }.join(', ')}"
  #puts "Complement Zodiac sign(s) are: #{zodiacComplements(current_zodiac_index).map { |index| zodiac_signs[index] }.join(', ')}"
   

# Output the result
#puts "Today is: #{current_month}"
#puts "Today is: #{current_day}"
#puts "The current Zodiac sign is: #{current_zodiac_sign}"


Battle::AbilityEffects::AfterMoveUseFromTarget.add(:ARIESBATTLECHARGE,
  proc { |ability, target, user, move, switched_battlers, battle|
    next if !move.damagingMove?
    #next if !(target.totalhp/2 > target.hp)
    next if !(((target.totalhp/5)*2) > target.hp)
	battle.pbShowAbilitySplash(target)
    battle.pbDisplay(_INTL("{1} will increase attack and speed with each hit under 40% HP!", target.pbThis, target.abilityName))
    next if !target.pbCanRaiseStatStage?(:ATTACK, target)
	target.pbRaiseStatStage(:ATTACK, 1, target)
    next if !target.pbCanRaiseStatStage?(:SPEED, target)
	target.pbRaiseStatStage(:SPEED, 1, target)
	battle.pbHideAbilitySplash(target)
  }
)

## TAURUS - HARDYBULL
#Battle::AbilityEffects::OnBeingHit.copy(:STAMINA, :TAURUSHARDYBULL)
Battle::AbilityEffects::OnBeingHit.add(:TAURUSHARDYBULL,
  proc { |ability, user, target, move, battle|
    if move.physicalMove?
      battle.pbShowAbilitySplash(target)
      battle.pbDisplay(_INTL("{1}'s Hardy Bull increases defense with each physical hit.", target.pbThis, target.abilityName))
      target.pbRaiseStatStage(:DEFENSE, 1, target)
      battle.pbHideAbilitySplash(target)
    end
    #target.pbRaiseStatStageByAbility(:DEFENSE, 1, target)
  }
)

## GEMINI - Party Starter
## Status moves targeting self receive priority
Battle::AbilityEffects::PriorityChange.add(:GEMINIPARTYSTARTER,
  proc { |ability, battler, move, pri|
    if move.target == :User && !move.damagingMove? # && move.statusMove?
      #puts 'Party Starter Activated'
      #battle.pbShowAbilitySplash(battler)
      battler.effects[PBEffects::GeminiPartyStarter] = true
      #battle.pbHideAbilitySplash(battler)
      next pri + 2
    end
  }
)
Battle::AbilityEffects::OnEndOfUsingMove.add(:GEMINIPARTYSTARTER,
  proc { |ability, user, targets, move, battle|
    if move.target == :User
      battle.pbShowAbilitySplash(user)
      battle.pbDisplay(_INTL("{1}'s Party Starter allowed it to move faster than usual!", user.pbThis))
      battle.pbHideAbilitySplash(user)
    end
    }
  )
#Battle::AbilityEffects::PriorityChange.add(:GALEWINGS,
#  proc { |ability, battler, move, pri|
#    next pri + 1 if (Settings::MECHANICS_GENERATION <= 6 || battler.hp == battler.totalhp) &&
#                    move.type == :FLYING
#  }
#)


## CANCER - Protective Shell
Battle::AbilityEffects::OnBeingHit.add(:CANCERPROTECTIVESHELL,
  proc { |ability, user, target, move, battle|
    #next if !move.pbContactMove?(user)
    if Effectiveness.super_effective?(target.damageState.typeMod)
      battle.pbShowAbilitySplash(target)
      battle.pbDisplay(_INTL("{1}'s protective shell reduced damage from the super effective move.", target.pbThis))
      #battle.pbDisplay(_INTL("{2}'s {1} reduced damage from the super effective move.", user.pbThis, ability.abilityName))
      battle.pbHideAbilitySplash(target)
    end
    }
)
#Battle::AbilityEffects::DamageCalcFromTarget.copy(:FILTER, :CANCERPROTECTIVESHELL)
Battle::AbilityEffects::DamageCalcFromTarget.add(:CANCERPROTECTIVESHELL,
  proc { |ability, user, target, move, mults, power, type|
    if Effectiveness.super_effective?(target.damageState.typeMod)
	  #battle.pbShowAbilitySplash(battler)
      mults[:final_damage_multiplier] *= 0.70
	  #battle.pbHideAbilitySplash(battler)
    end
  }
)

Battle::AbilityEffects::OnBattlerFainting.add(:LEOPRIDEFULROAR,
  proc { |ability, battler, fainted, battle|
  #  battler.pbRaiseStatStageByAbility(:SPECIAL_ATTACK, 1, battler)
  #}
    next if !battler.canHeal?
    battle.pbShowAbilitySplash(battler)
    battler.pbRecoverHP(battler.totalhp / 4)
    if Battle::Scene::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s Prideful Roar restores its HP!", battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1}'s Prideful Roar restores its HP!", battler.pbThis, battler.abilityName))
    end
    battle.pbHideAbilitySplash(battler)
    if battler.status != :NONE
      battle.pbHideAbilitySplash(battler)
    end
    
    next if battler.status == :NONE
    #next if ![:Rain, :HeavyRain].include?(battler.effectiveWeather)
    battle.pbShowAbilitySplash(battler)
    oldStatus = battler.status
    battler.pbCureStatus(Battle::Scene::USE_ABILITY_SPLASH)
    if !Battle::Scene::USE_ABILITY_SPLASH
      case oldStatus
      when :SLEEP
        battle.pbDisplay(_INTL("{1}'s Prideful Roar woke it up!", battler.pbThis, battler.abilityName))
      when :POISON
        battle.pbDisplay(_INTL("{1}'s Prideful Roar cured its poison!", battler.pbThis, battler.abilityName))
      when :BURN
        battle.pbDisplay(_INTL("{1}'s Prideful Roar healed its burn!", battler.pbThis, battler.abilityName))
      when :PARALYSIS
        battle.pbDisplay(_INTL("{1}'s Prideful Roar cured its paralysis!", battler.pbThis, battler.abilityName))
      when :FROZEN
        battle.pbDisplay(_INTL("{1}'s Prideful Roar defrosted it!", battler.pbThis, battler.abilityName))
      end
    end
    battle.pbHideAbilitySplash(battler)
  }
)

## VIRGO - Pure Focus - The Pokémon stats cannot be lowered in battle.
Battle::AbilityEffects::StatLossImmunity.copy(:CLEARBODY, :VIRGOPUREFOCUS)

#Battle::AbilityEffects::StatusImmunity.add(:VIRGOPUREFOCUS,
#  proc { |ability, battler, status, battle, showMessages|
#    if 1==1
      #battle.pbShowAbilitySplash(battler)
#      @battle.pbDisplay(_INTL("{1}'s VIRGO sign resists status effects.", battler.pbThis))  
#      ret true
      #battle.pbHideAbilitySplash(battler)
#    end
#  }
#)
#Battle::AbilityEffects::OnBeingHit.add(:VIRGOPUREFOCUS,
#  proc { |ability, user, target, move, battle|
#      if user.pbCanSleep?(target) or user.pbCanPoison?(target) or user.pbCanParalyze?(target) or user.pbCanFreeze?(target)
#      battle.pbShowAbilitySplash(target)
#      if !Battle::Scene::USE_ABILITY_SPLASH
#        msg = _INTL("{1}'s {2} resists the status effect.", target.pbThis, target.abilityName)
#      end
#      battle.pbHideAbilitySplash(target)
#      }
#)

# Steady Gaze - Increases accuracy by one stage when using a non-damaging move.
# VIRGOSTEADYGAZE
#Battle::AbilityEffects::OnDealingHit.add(:VIRGOPUREFOCUS,
#  proc { |ability, battler, move, pri, status|
#move.damagingMove? move.statusMove? 
#    if !move.damagingMove? && battler.pbCanRaiseStatStage?(:ACCURACY, battler)
#      battle.pbShowAbilitySplash(battler)
#      target.pbRaiseStatStageByAbility(:ACCURACY, 1, battler)
#      battle.pbHideAbilitySplash(battler)
#    end
#    }
#)

## LIBRA
# Harmony Guard
# 10 pct chance heals 1/2 hp after being hit
Battle::AbilityEffects::OnBeingHit.add(:LIBRAHARMONYGUARD,
  proc { |ability, user, target, move, battle|
    if rand(1..10) == 1 and target.canHeal?
      battle.pbShowAbilitySplash(target)
      if !Battle::Scene::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s Harmony Guard restored some health!", target.pbThis, target.abilityName)
      end
      target.pbRecoverHP(target.totalhp / 2)
      battle.pbHideAbilitySplash(target)
    end
    }
)

# Harmonize - Heals 1/8th max HP if 
# the Pokemon uses a move that inflicts a status condition on the opponent.
#Battle::AbilityEffects::OnStatusInflicted.add(:LIBRAHARMONIZE,
#  proc { |ability, battler, user, status|
#Battle::AbilityEffects::OnDealingHit.add(:LIBRAHARMONIZE,
#  proc { |ability, user, target, move, battle|
#  next if user.canHeal?
#    battle.pbShowAbilitySplash(target)
#    user.pbRecoverHP(user.totalhp / 8)
#    if Battle::Scene::USE_ABILITY_SPLASH
#      battle.pbDisplay(_INTL("{1}'s HP was restored.", target.pbThis))
#    else
#      battle.pbDisplay(_INTL("{1}'s {2} restored its HP.", target.pbThis, target.abilityName))
#    end
#    battle.pbHideAbilitySplash(target)
#  }
#)
    
## SCORPIO - VENOMOUS STARE
Battle::AbilityEffects::EndOfRoundEffect.add(:SCORPIOVENOMSTARE,
  proc { |ability, battler, battle|
  battle.allOtherSideBattlers(battler.index).each do |b|
    next if !b.near?(battler)
	  if rand(1..5) == 5
      if b.pbCanPoison?(battler, Battle::Scene::USE_ABILITY_SPLASH)
        msg = nil
        battle.pbShowAbilitySplash(battler)
        if !Battle::Scene::USE_ABILITY_SPLASH
          msg = _INTL("{1}'s venomous stare badly poisoned {3}!", battler.pbThis, battler.abilityName, b.pbThis(true))
        end
		   #battle.scene.pbDamageAnimation(b)
		   b.pbPoison(battler, msg, true) # , true = toxic
		   battle.pbHideAbilitySplash(battler)
      end
	  end
	end
  }
)
#Battle::AbilityEffects::OnBeingHit.add(:SCORPIOVENOMSTARE,
#  proc { |ability, user, target, move, battle|
#    next if user.poisoned? || battle.pbRandom(100) >= 30
#    battle.pbShowAbilitySplash(target)
#    if user.pbCanPoison?(target, Battle::Scene::USE_ABILITY_SPLASH) 
#      msg = nil
#      if !Battle::Scene::USE_ABILITY_SPLASH
#        msg = _INTL("{1}'s {2} badly poisoned {3}!", target.pbThis, target.abilityName, user.pbThis(true))
#      end
#      user.pbPoison(target, msg, true) # , true = toxic
#    end
#    battle.pbHideAbilitySplash(target)
#  }
#)

## SAGITTAIRUS - Sharp Eye
Battle::AbilityEffects::CriticalCalcFromUser.copy(:SUPERLUCK, :SAGITTARIUSSHARPEYE)
#Battle::AbilityEffects::CriticalCalcFromUser.add(:SUPERLUCK,
#  proc { |ability, user, target, c|
#    next c + 1
#  }
#)

## CAPRICORN - Enduring Will
# Enduring Will - Boosts defense and special defense by one stage when HP drops below half.
#Battle::AbilityEffects::OnBeingHit.add(:CAPRICORNENDURINGWILL,
 # proc { |ability, user, target, move, battle|
  
#Battle::AbilityEffects::AfterMoveUseFromTarget.add(:CAPRICORNENDURINGWILL,
#  proc { |ability, target, user, move, switched_battlers, battle, battler|
#    next if !move.damagingMove?
#    next if !target.droppedBelowHalfHP
#	battle.pbShowAbilitySplash(target)
#	next if !target.pbCanRaiseStatStage?(:DEFENSE, target)
#	target.pbRaiseStatStage(:DEFENSE, 1, target)
#    next if !target.pbCanRaiseStatStage?(:SPECIAL_DEFENSE, target)
#	target.pbRaiseStatStage(:SPECIAL_DEFENSE, 1, target)
#	battle.pbHideAbilitySplash(target)
#  }
#)
Battle::AbilityEffects::AfterMoveUseFromTarget.add(:CAPRICORNENDURINGWILL,
  proc { |ability, target, user, move, switched_battlers, battle|
    next if !move.damagingMove?
    #next if !(target.totalhp/2 > target.hp)
    next if !(((target.totalhp/5)*2) > target.hp)
	battle.pbShowAbilitySplash(target)
  battle.pbDisplay(_INTL("{1} will increase defenses with each hit under 40% HP!", target.pbThis, target.abilityName))

    next if !target.pbCanRaiseStatStage?(:DEFENSE, target)
	target.pbRaiseStatStage(:DEFENSE, 1, target)
    next if !target.pbCanRaiseStatStage?(:SPECIAL_DEFENSE, target)
	target.pbRaiseStatStage(:SPECIAL_DEFENSE, 1, target)
	battle.pbHideAbilitySplash(target)
  }
)

## Aquarius Innovative Spark
# Innovative Spark - Randomly boosts one of the Pokemon's
# stats by one stage at the beginning of each battle.
Battle::AbilityEffects::OnSwitchIn.add(:AQUARIUSINNOVATIVESPARK,
  proc { |ability, battler, battle, switch_in|
  announce_moon_sign(battler, battle, current_zodiac_sign, current_moon_day, current_moon_phase, ability)
    if current_zodiac_sign == 'Aquarius'
      moon_sign(battler, battle, current_zodiac_sign)
    end
  # Output the result
  #puts "Today month is: #{current_month}"
  #puts "Today day is: #{current_day}"
  #puts "Current Zodiac sign is: #{current_zodiac_sign}"
  
# Correct method calls with parentheses
  #puts "Opposite Zodiac sign is: #{zodiac_signs[zodiacOpposite(current_zodiac_index)]}"
  #puts "Partner Zodiac sign(s) are: #{zodiacPartners(current_zodiac_index).map { |index| zodiac_signs[index] }.join(', ')}"
  #puts "Complement Zodiac sign(s) are: #{zodiacComplements(current_zodiac_index).map { |index| zodiac_signs[index] }.join(', ')}"
    
    stats = ["ATTACK","DEFENSE","SPECIAL_ATTACK","SPECIAL_DEFENSE","SPEED"]
    first_stat = stats.sample
    stat1 = first_stat.to_sym

    if battler.pbCanRaiseStatStage?(stat1, battler, self)
      battle.pbShowAbilitySplash(battler)
      #battle.pbDisplay(_INTL("{2}'s innovative spark raises {1}'s #{stat1}.", battler.pbThis, battler.abilityName)) # This works, just didn't want it
      battle.pbDisplay(_INTL("{2}'s innovative spark raises a random stat.", battler.pbThis, battler.abilityName))
      battler.pbRaiseStatStage(stat1, 1, battler)
      battle.pbHideAbilitySplash(battler)
    end
  }
)

## Pisces - Mystic Veil - Reduces damage from special attacks by 30%. 
Battle::AbilityEffects::OnBeingHit.add(:PISCESMYSTICVEIL,
  proc { |ability, user, target, move, battle|
    #next if !move.pbContactMove?(user)
    if move.specialMove? || move.function_code == "UseTargetDefenseInsteadOfTargetSpDef" 
      battle.pbShowAbilitySplash(target)
      #battle.pbDisplay(_INTL("{1}'s mystic veil reduced damage from the special move.", target.pbThis))
      battle.pbDisplay(_INTL("{2}'s mystic veil reduced damage from the special move.", target.pbThis, target.abilityName))
      battle.pbHideAbilitySplash(target)
    end
    }
)

Battle::AbilityEffects::DamageCalcFromTarget.add(:PISCESMYSTICVEIL,
  proc { |ability, user, target, move, mults, power, type|
  
    mults[:defense_multiplier] *= 2 if move.specialMove? ||
                                       move.function_code == "UseTargetDefenseInsteadOfTargetSpDef"   # Psyshock

    }

)

##########################################
#### SWITCH IN MOON SIGN STAT BOOSTS ####
#########################################

## Aries
Battle::AbilityEffects::OnSwitchIn.add(:ARIESBATTLECHARGE,
  proc { |ability, battler, battle, switch_in|
    announce_moon_sign(battler, battle, current_zodiac_sign, current_moon_day, current_moon_phase, ability)
    if current_zodiac_sign == 'Aries'
      moon_sign(battler, battle, current_zodiac_sign)
    end
  }
)

## Taurus
Battle::AbilityEffects::OnSwitchIn.add(:TAURUSHARDYBULL,
  proc { |ability, battler, battle, switch_in|
    announce_moon_sign(battler, battle, current_zodiac_sign, current_moon_day, current_moon_phase, ability)
    if current_zodiac_sign == 'Taurus'
      moon_sign(battler, battle, current_zodiac_sign)
    end
  }
)

## Gemini
Battle::AbilityEffects::OnSwitchIn.add(:GEMINIPARTYSTARTER,
  proc { |ability, battler, battle, switch_in|
    announce_moon_sign(battler, battle, current_zodiac_sign, current_moon_day, current_moon_phase, ability)
    if current_zodiac_sign == 'Gemini'
      moon_sign(battler, battle, current_zodiac_sign)
    end
  }
)

## Cancer
Battle::AbilityEffects::OnSwitchIn.add(:CANCERPROTECTIVESHELL,
  proc { |ability, battler, battle, switch_in|
    announce_moon_sign(battler, battle, current_zodiac_sign, current_moon_day, current_moon_phase, ability)
    if current_zodiac_sign == 'Cancer'
      moon_sign(battler, battle, current_zodiac_sign)
    end
  }
)

## Leo
Battle::AbilityEffects::OnSwitchIn.add(:LEOPRIDEFULROAR,
  proc { |ability, battler, battle, switch_in|
    announce_moon_sign(battler, battle, current_zodiac_sign, current_moon_day, current_moon_phase, ability)
    if current_zodiac_sign == 'Leo'
      moon_sign(battler, battle, current_zodiac_sign)
    end
  }
)

## Virgo
Battle::AbilityEffects::OnSwitchIn.add(:VIRGOPUREFOCUS,
  proc { |ability, battler, battle, switch_in|
    announce_moon_sign(battler, battle, current_zodiac_sign, current_moon_day, current_moon_phase, ability)
    if current_zodiac_sign == 'Virgo'
      moon_sign(battler, battle, current_zodiac_sign)
    end
  }
)

## Libra
Battle::AbilityEffects::OnSwitchIn.add(:LIBRAHARMONYGUARD,
  proc { |ability, battler, battle, switch_in|
    announce_moon_sign(battler, battle, current_zodiac_sign, current_moon_day, current_moon_phase, ability)
    if current_zodiac_sign == 'Libra'
      moon_sign(battler, battle, current_zodiac_sign)
    end
  }
)

## Scorpio
Battle::AbilityEffects::OnSwitchIn.add(:SCORPIOVENOMSTARE,
  proc { |ability, battler, battle, switch_in|
  announce_moon_sign(battler, battle, current_zodiac_sign, current_moon_day, current_moon_phase, ability)
    if current_zodiac_sign == 'Scorpio'
      moon_sign(battler, battle, current_zodiac_sign)
    end
  }
)

## Sagittarius
Battle::AbilityEffects::OnSwitchIn.add(:SAGITTARIUSSHARPEYE,
  proc { |ability, battler, battle, switch_in|
    announce_moon_sign(battler, battle, current_zodiac_sign, current_moon_day, current_moon_phase, ability)
    if current_zodiac_sign == 'Sagittarius'
      moon_sign(battler, battle, current_zodiac_sign)
    end
  }
)

## Capricorn
Battle::AbilityEffects::OnSwitchIn.add(:CAPRICORNENDURINGWILL,
  proc { |ability, battler, battle, switch_in|
    announce_moon_sign(battler, battle, current_zodiac_sign, current_moon_day, current_moon_phase, ability)
    if current_zodiac_sign == 'Capricorn'
      moon_sign(battler, battle, current_zodiac_sign)
    end
  }
)

## Aquarius - Needs to be part of the same switch-in function
#Battle::AbilityEffects::OnSwitchIn.add(:AQUARIUSINNOVATIVESPARK,
#  proc { |ability, battler, battle, switch_in|
#    if current_zodiac_sign == 'Aquarius'
#      moon_sign(battler, battle, current_zodiac_sign)
#    end
#  }
#)

## Pisces
Battle::AbilityEffects::OnSwitchIn.add(:PISCESMYSTICVEIL,
  proc { |ability, battler, battle, switch_in|
    announce_moon_sign(battler, battle, current_zodiac_sign, current_moon_day, current_moon_phase, ability)
    if current_zodiac_sign == 'Pisces'
      moon_sign(battler, battle, current_zodiac_sign)
    end
  }
)

########### CRITICAL HIT HANDLER ###########
Battle::AbilityEffects::CriticalCalcFromUser.add(:ARIESBATTLECHARGE,
  proc { |ability, user, target, c, battle|
  if [8, 18, 27].include?(moonphase_day(pbGetTimeNow())-1)
    puts "Critical Hits were raised"
    next c + 1
  end
  #next 99
     }
    )
    
Battle::AbilityEffects::CriticalCalcFromUser.copy(:ARIESBATTLECHARGE,:TAURUSHARDYBULL,:GEMINIPARTYSTARTER,:CANCERPROTECTIVESHELL,:LEOPRIDEFULROAR,:VIRGOPUREFOCUS,:LIBRAHARMONYGUARD,:SCORPIOVENOMSTARE,:SAGITTARIUSSHARPEYE,:CAPRICORNENDURINGWILL,:AQUARIUSINNOVATIVESPARK,:PISCESMYSTICVEIL)

############ STATUS IMMUNITY ###########
Battle::AbilityEffects::StatusImmunity.add(:ARIESBATTLECHARGE,
  proc { |ability, battler, status|
    if [7, 14, 22].include?(moonphase_day(pbGetTimeNow())-1)
      puts "Status Immunity"
      next true
    end
    }
)

Battle::AbilityEffects::StatusImmunity.copy(:ARIESBATTLECHARGE,:TAURUSHARDYBULL,:GEMINIPARTYSTARTER,:CANCERPROTECTIVESHELL,:LEOPRIDEFULROAR,:VIRGOPUREFOCUS,:LIBRAHARMONYGUARD,:SCORPIOVENOMSTARE,:SAGITTARIUSSHARPEYE,:CAPRICORNENDURINGWILL,:AQUARIUSINNOVATIVESPARK,:PISCESMYSTICVEIL)

