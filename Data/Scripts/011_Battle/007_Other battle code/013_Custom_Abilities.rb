

#===================
# CATCHPHRASE
#===================
Battle::AbilityEffects::OnBeingHit.add(:CATCHPHRASE,
  proc { |ability, user, target, move, battle|
    next if !target.damageState.critical
    battle.pbShowAbilitySplash(target)
    quotes = ["Looks like you're my new rival..","I don't like this","WAAAAH","V sad","Godddamit!!","Bully! Bully! Bully!"]
    battle.pbDisplay(_INTL("{1}: {2}", target.pbThis, quotes.sample))
    battle.pbHideAbilitySplash(target)
  }
)
Battle::AbilityEffects::OnDealingHit.add(:CATCHPHRASE,
  proc { |ability, user, target, move, battle|
  if (target.damageState.critical or target.damageState.typeMod >= 2 )
   # next if (!target.damageState.critical or target.damageState.typeMod >= 2 )
    battle.pbShowAbilitySplash(user)
    quotes = ["Hahaha!","Hahaha! Take that!","Cooool!"]
    battle.pbDisplay(_INTL("{1}: {2}", user.pbThis, quotes.sample))
    battle.pbHideAbilitySplash(user)
  end
  }
)

#################
## High ALERT
#################
Battle::AbilityEffects::ChangeOnBattlerFainting.add(:HIGHALERT,
proc { |ability, battler, fainted, battle|
    
#Battle::AbilityEffects::OnSwitchIn.add(:HIGHALERT,
#  proc { |ability, battler, battle, switch_in|
    #battle.pbShowAbilitySplash(battler)
    stats = ["ATTACK","SPECIAL_ATTACK"]
    selected_stat = stats.sample.to_sym
    
    if battler.turnCount > 0 && battle.choices[battler.index][0] != :Run &&
      battler.pbCanRaiseStatStage?(selected_stat, battler)
      battler.pbRaiseStatStageByAbility(selected_stat, 1, battler)

      battle.pbDisplay(_INTL("{1} is alert to the continued danger...", battler.pbThis))
      #battle.pbHideAbilitySplash(battler)
    end
  }
)

####
# CHONKY THIGHS
####
Battle::AbilityEffects::DamageCalcFromUser.add(:CHONKYTHIGHS,
  proc { |ability, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if move.kickingMove?
  }
)

####
## KPOP DANCER
###
Battle::AbilityEffects::DamageCalcFromUser.add(:KPOPDANCER,
  proc { |ability, user, target, move, mults, power, type|
    # Dance moves do extra 20% damage
    mults[:power_multiplier] *= 1.2 if move.danceMove?
    #puts "Power Multiplied"
  }
)

Battle::AbilityEffects::OnDealingHit.add(:KPOPDANCER,
  proc { |ability, user, target, move, battle|
  # Dance moves restore 1/4 HP
    if target.damageState.hpLost > 0 and move.danceMove?
      battle.pbShowAbilitySplash(user)
      #battle.pbDisplay(_INTL("{1} recovers HP from dancing.", user.pbThis))
      hpGain = (target.damageState.hpLost / 4.0).round
      user.pbRecoverHPFromDrain(hpGain, target, msg = _INTL("{1} recovers HP from dancing.", user.pbThis))
      battle.pbHideAbilitySplash(user)
      #puts "Hp Restore"
    end
  }
)

#####
## INJURY PRONE
#####
Battle::AbilityEffects::DamageCalcFromUser.add(:INJURYPRONE,
  proc { |ability, user, target, move, mults, power, type|
    # Kicking moves do extra 20% damage
    mults[:power_multiplier] *= 1.2 if move.kickingMove?
    #puts "Power Multiplied"
  }
)

Battle::AbilityEffects::OnBeingHit.add(:INJURYPRONE,
  proc { |ability, user, target, move, battle|
  
  roll = rand(1..20)
  #roll = 1
  
  if roll == 1
    next if !move.pbContactMove?(user)
    next if user.paralyzed?
    battle.pbShowAbilitySplash(target)
    if user.pbCanParalyze?(target, Battle::Scene::USE_ABILITY_SPLASH) &&
       target.affectedByContactEffect?(Battle::Scene::USE_ABILITY_SPLASH)
      msg = nil
      if !Battle::Scene::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} paralyzed themself! It may be unable to move!",
           target.pbThis, target.abilityName)
      end
      target.pbParalyze(user, msg)
    end
    battle.pbHideAbilitySplash(target)
  end
    
  if roll >= 2 and roll <= 3
    stats = ["ATTACK","DEFENSE"]
    selected_stat = stats.sample.to_sym
  
    target.pbLowerStatStageByAbility(selected_stat, 1, target)
  end
  }
)

#####
## FINAL ACT
#####
Battle::AbilityEffects::DamageCalcFromUser.add(:ALLERGIES,
  proc { |ability, user, target, move, mults, power, type|
    if user.hp <= user.totalhp / 3
      mults[:attack_multiplier] *= 1.2
    end
  }
)

# Weakness to Grass, Bug, Powder Moves
Battle::AbilityEffects::DamageCalcFromTarget.add(:ALLERGIES,
  proc { |ability, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if (type == :GRASS or type == :BUG or move.powderMove?)
  }
)


# 1.5x Boost to all physical attacks when under 1/3 hp
Battle::AbilityEffects::DamageCalcFromUser.add(:IRONWILL,
  proc { |ability, user, target, move, mults, power, type|
    if (user.hp <= user.totalhp / 3 or user.pbHasAnyStatus?) && move.physicalMove?
      mults[:attack_multiplier] *= 1.5
    end
  }
)

#Battle::AbilityEffects::ModifyMoveBaseType.add(:PANICMODE,
#  proc { |ability, user, move, type|
#    @potential_moves = []
#    user.eachMoveWithIndex do |m, i|
#      next if !@battle.pbCanChooseMove?(user.index, i, false, true)
#      next if !user.asleep? || @potential_moves.length == 0
#      @potential_moves.push(i)
#    end
  
    #return @potential_moves[sample]
#    choice = @potential_moves[@battle.pbRandom(@potential_moves.length)]
#    return user.pbUseMoveSimple(user.moves[choice].id, user.pbDirectOpposing.index)
#  }
#)
