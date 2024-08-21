## Custom Function Codes for Moves go here

#===============================================================================
# Increases the user's Attack, Defense by 2 stages, and confuses self (Caffeine Boost)
#===============================================================================
class Battle::Move::RaiseUserAttack2ConfuseSelf < Battle::Move::MultiStatUpMove
    def initialize(battle, move)
      super
      @statUp = [:ATTACK, 2, :DEFENSE, 2]
    end  
    
      ## Add in a clause that may also paralyze self
    def pbEffectGeneral(user)
      super
      
      if user.pbCanConfuseSelf?(false)
        user.pbConfuse(_INTL("{1} has a caffeine headache!", user.pbThis))
      end
      
      ## 10% chance to paralyze self
      if rand(1..10) == 10
        if user.pbCanParalyze?(false)
          user.pbParalyze(_INTL("{1} is paralyzed from caffeine!", user.pbThis))
        end
      end
   
    end
  end
  
  #===============================================================================
  # Increases the user's SpD, Speed by 1 Stage (Wetsuit)
  #===============================================================================
  class Battle::Move::RaiseUserSpecialDefense1Speed1 < Battle::Move::MultiStatUpMove
    def initialize(battle, move)
      super
      @statUp = [:SPECIAL_DEFENSE, 1, :SPEED, 1]
    end
  end
  
  #===============================================================================
  # Exaggerate Self - Healing move - with variance and chance to confuse
  #===============================================================================
  class Battle::Move::HealUserVarTotalHP < Battle::Move::HealingMove
    
            ## 20% chance to confuse self
            def pbEffectGeneral(user)
              puts "======================="
              puts "Trigger Attack"
              
              rand_value = rand(1..10)
              #puts rand_value
              if rand_value <= 2
                puts "Confuse Self"
                
                #if user.pbCanConfuseSelf?(false)
                if user.effects[PBEffects::Confusion]==0
                  user.pbConfuse(_INTL("{1} just confused themself!", user.pbThis))
                else
                  @battle.pbDisplay(_INTL("{1}'s confusion continues...", user.pbThis))  
                end
              else
                super
              end
            end
            
            #  def pbMoveFailed?(user, targets)
            #    hpLoss = [user.totalhp / 2, 1].max
            #    if user.effects[PBEffects::Confusion]>0
            #      @battle.pbDisplay(_INTL("User Confused. Can't Heal."))
            #      return true
            #    end
            #    return false
            #  end
                
             def pbHealAmount(user)
                  super
                  #puts "Heal Self"
                  factor = rand(17..40).to_f / 10
                  #puts factor
                  #puts user.totalhp
                  return (user.totalhp / factor).round
            end
    end
    
  #===============================================================================
  # Move works better on specific gender (Male) + flinch chance
  #===============================================================================
  class Battle::Move::MaleTargetFlinch < Battle::Move
    #def ignoresSubstitute?(user); return true; end
    #def canMagicCoat?; return true; end
  
    def pbBaseDamage(baseDmg, user, target)
      if target.gender == 0
        @battle.pbDisplay(_INTL("{1}'s move deals additional damage to males.", user.pbThis))  
        baseDmg = baseDmg * 1.5
        return baseDmg
      else
        baseDmg = baseDmg
      end
      return baseDmg
    end
    
    def flinchingMove?; return true; end
  
    def pbEffectAgainstTarget(user, target)
      return if damagingMove?
      target.pbFlinch(user)
    end
  
    def pbAdditionalEffect(user, target)
      return if target.damageState.substitute
      target.pbFlinch(user)
    end
    
  end
  
  #===============================================================================
  # Move works better on specific gender (Female) + flinch chance
  #===============================================================================
  class Battle::Move::FemaleTargetFlinch < Battle::Move
    #def ignoresSubstitute?(user); return true; end
    #def canMagicCoat?; return true; end
  
    def pbBaseDamage(baseDmg, user, target)
      if target.gender == 1
        @battle.pbDisplay(_INTL("{1}'s move deals additional damage to females.", user.pbThis))  
        baseDmg = baseDmg * 1.5
      else
        baseDmg = baseDmg
      end
      return baseDmg
    end
    
    def flinchingMove?; return true; end
  
    def pbEffectAgainstTarget(user, target)
      return if damagingMove?
      target.pbFlinch(user)
    end
  
    def pbAdditionalEffect(user, target)
      return if target.damageState.substitute
      target.pbFlinch(user)
    end
    
  end
  #===============================================================================
  # Reduces the user's HP by 5/8 of max, and sets its SpAttack to maximum.
  # (Drugs)
  #===============================================================================
  class Battle::Move::MaxUserSpAttackLoseHPPoisonChance < Battle::Move
    attr_reader :statUp
  
    def canSnatch?; return true; end
  
    def initialize(battle, move)
      super
      @statUp = [:SPECIAL_ATTACK, 8]
    end
  
    def pbMoveFailed?(user, targets)
      ### Remove checks for HP levels when using drugs
      ## As it is a very irresponsible attack
      
      #hpLoss = [user.totalhp / 2, 1].max
      #hpLoss = [user.totalhp / 2, 1].max
      #if user.hp <= hpLoss
      #  @battle.pbDisplay(_INTL("But it failed!"))
      #  return true
      #end
      #return true if !user.pbCanRaiseStatStage?(@statUp[0], user, self, true)
      #return false
    end
  
    def pbEffectGeneral(user)
      #hpLoss = [user.totalhp / 2, 1].max
      rand_factor = rand(1.5..3.0)
      #puts "Rand Factor"
      #puts rand_factor
      hpLoss = [user.totalhp / rand_factor, 1].max
      #puts "hpLoss"
      #puts hpLoss
      user.pbReduceHP(hpLoss, false, false)
      if user.hasActiveAbility?(:CONTRARY)
        user.stages[@statUp[0]] = -Battle::Battler::STAT_STAGE_MAXIMUM
        user.statsLoweredThisRound = true
        user.statsDropped = true
        @battle.pbCommonAnimation("StatDown", user)
        @battle.pbDisplay(_INTL("{1} took some drugs to reduce their {2}!",
           user.pbThis, GameData::Stat.get(@statUp[0]).name))
      else
        user.stages[@statUp[0]] = Battle::Battler::STAT_STAGE_MAXIMUM
        user.statsRaisedThisRound = true
        @battle.pbCommonAnimation("StatUp", user)
        @battle.pbDisplay(_INTL("{1} took some drugs to boost their {2}!",
           user.pbThis, GameData::Stat.get(@statUp[0]).name))
      end
      user.pbItemHPHealCheck
      
      ## Add 10% possibility of self poison
      if rand(1..10) == 1 and !user.poisoned?
        user.pbPoison(_INTL("{1} is poisoned from drugs!", user.pbThis))
      end
    end
    
  end
  
  #===============================================================================
  # Toxic/LeechSeed Combo
  #===============================================================================
  class Battle::Move::MyceliumDrain < Battle::Move
    #def canMagicCoat?; return true; end
  
    def pbFailsAgainstTarget?(user, target, show_message)
      if target.effects[PBEffects::LeechSeed] >= 0
        @battle.pbDisplay(_INTL("{1} evaded the attack!", target.pbThis)) if show_message
        return true
      end
      #if target.pbHasType?(:GRASS)
      #  @battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true))) if show_message
      #  return true
      #end
      return false
    end
  
    def pbMissMessage(user, target)
      @battle.pbDisplay(_INTL("{1} evaded the attack!", target.pbThis))
      return true
    end
  
    def pbEffectAgainstTarget(user, target)
      target.effects[PBEffects::LeechSeed] = user.index
      #target.pbPoison(user = nil, msg = nil, toxic=true)
      #target.pbPoison(toxic=true)
      target.pbPoison(target, msg = nil, true)
      #if target.pbCanPoison?(false)
        
      #end
      @battle.pbDisplay(_INTL("{1} was infected by mycelium!", target.pbThis))
    end
    
  end
  
  #===============================================================================
  # User passes out to drastically boost all defences for a number of turns (Faint)
  #===============================================================================
  class Battle::Move::SleepFaintBoostDefences < Battle::Move::MultiStatUpMove
    def initialize(battle, move)
      super
      @statUp = [:DEFENSE, 12, :SPECIAL_DEFENSE, 12]
    end  
    
    def pbMoveFailed?(user, targets)
      if user.asleep?
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return true if !user.pbCanSleep?(user, true, self, true)
      return true if super
      return false
    end
  
   # def pbHealAmount(user)
   #   return user.totalhp - user.hp
   # end
  
    def pbEffectGeneral(user)
      user.pbSleepSelf(_INTL("{1} had too much soju and passed out!", user.pbThis), 5)
      super
    end
  end

#===============================================================================
# Spicy Noodles Calc
#===============================================================================
class Battle::Move::SpicyNoodlesCalc < Battle::Move::SleepTarget

  def pbOnStartUse(user, targets)
    baseDmg = [40, 55, 70, 90, 110]
    spicy_val = rand(0..4)
    @spicy_dmg = baseDmg[spicy_val]
    @battle.pbDisplay(_INTL("x{1} Spicy Noodles!", spicy_val + 1))
  end

  def pbBaseDamage(baseDmg, user, target)
    return @spicy_dmg
  end
  
	def pbCalcTypeModSingle(moveType, defType, user, target)
    if target.isSpecies?(:JJ)
      @battle.pbDisplay(_INTL("Spicy Noodles is super-effective against {1}!", target.pbThis))
      return Effectiveness::SUPER_EFFECTIVE_MULTIPLIER if target.isSpecies?(:JJ)
    end
		return super
	end

	def canMagicCoat?; return true; end

	def pbFailsAgainstTarget?(user, target, show_message)
		return false if damagingMove?
		return !target.pbCanBurn?(user, show_message, self)
	end

	def pbEffectAgainstTarget(user, target)
		return if damagingMove?
		target.pbBurn(user)
	end

	def pbAdditionalEffect(user, target)
		return if target.damageState.substitute
		target.pbBurn(user) if target.pbCanBurn?(user, false, self)
	end	
end

#===============================================================================
# Cosplay Function
#===============================================================================
# Battler_ChangeSelf
  def pbCosplay(target)
    oldAbil = @ability_id
    @effects[PBEffects::Transform]        = true
    @effects[PBEffects::TransformSpecies] = target.species
    pbChangeTypes(target)
    #self.ability = target.ability
    self.ability = "INCHARACTER"
    @attack  = [target.attack, self.attack].max #target.attack
    @defense = [target.defense, self.defense].max #target.defense
    @spatk   = [target.spatk, self.spatk].max #target.spatk
    @spdef   = [target.spdef, self.spdef].max #target.spdef
    @speed   = [target.speed, self.speed].max #target.speed
    GameData::Stat.each_battle { |s| @stages[s.id] = target.stages[s.id] }
    if Settings::NEW_CRITICAL_HIT_RATE_MECHANICS
      @effects[PBEffects::FocusEnergy] = target.effects[PBEffects::FocusEnergy]
      @effects[PBEffects::LaserFocus]  = target.effects[PBEffects::LaserFocus]
    end
    @moves.clear
    target.moves.each_with_index do |m, i|
      @moves[i] = Battle::Move.from_pokemon_move(@battle, Pokemon::Move.new(m.id))
      @moves[i].pp       = 15
      @moves[i].total_pp = 15
      #@moves[3] = Battle::Move.  
      # if PBMoves.getName(@moves[i]) != "COSPLAY"
      #from_pokemon_move(@battle, Pokemon::Move.new(@currentMove))
      #pbLearnMove(self, :COSPLAY) 
      #@moves[3] = :COSPLAY
      #end
    end
    @effects[PBEffects::Disable]      = 0
    @effects[PBEffects::DisableMove]  = nil
    @effects[PBEffects::WeightChange] = target.effects[PBEffects::WeightChange]
    @battle.scene.pbRefreshOne(@index)
    @battle.pbDisplay(_INTL("{1} transformed into {2}!", pbThis, target.pbThis(true)))
    pbOnLosingAbility(oldAbil)
    
  end
  
# Battler Other
#===============================================================================
# COSPLAY - User transforms into the target. (Transform)
#===============================================================================
class Battle::Move::CosplayUserIntoTarget < Battle::Move::MultiStatUpMove

  def pbMoveFailed?(user, targets)
    if user.effects[PBEffects::Transform]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    if target.effects[PBEffects::Transform] ||
       target.effects[PBEffects::Illusion]
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end

  
  def pbEffectAgainstTarget(user, target)
    #@statUp = [:SPEED, 1]
    
    stats = ["DEFENSE","ATTACK","SPECIAL_ATTACK","SPECIAL_DEFENSE"]
    first_stat = stats.sample
    stat1 = first_stat.to_sym

    ## Select a second random stat, minus the stat already selected
    remaining_stats = stats - [first_stat]
    second_stat = remaining_stats.sample
    stat2 = second_stat.to_sym
    
    stat_inc = [stat1, 1, stat2, 1]
    #stat_inc = [:SPEED, 1, stat1, 1]
    # puts stat_inc.inspect
    @statUp = stat_inc
    user.pbCosplay(target)
  end

  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    super
    @battle.scene.pbChangePokemon(user, targets[0].pokemon)
  end
  
end

#===============================================================================
# Decreases all users stats by 5 stages (Chaotic Tendrils)
#===============================================================================

class Battle::Move::LowerAllStats5 < Battle::Move::StatDownMove
  def initialize(battle, move)
    super
    @statDown = [:ATTACK, 5, :DEFENSE, 5, :SPECIAL_ATTACK, 5, :SPECIAL_DEFENSE, 5, :SPEED, 5]
  end
end

#===============================================================================
# Commando Roll - Boost Speed and Evasion
#===============================================================================
  class Battle::Move::IncreaseSpeed1Evasion1 < Battle::Move::MultiStatUpMove
    def initialize(battle, move)
      super
      @statUp = [:SPEED, 1, :EVASION, 1]
    end  
  end
  
#===============================================================================
# Mycelium Rain
#===============================================================================
class Battle::Move::MyceliumRain < Battle::Move
    ## Poison target
    def pbEffectAgainstTarget(user, target)
      return if target.damageState.substitute
      if target.pbCanPoison?(user, false, self)
        return target.pbPoison(target, msg = nil, true)
      end
    end
    
  def pbEffectAfterAllHits(user, target)
    if !target.damageState.unaffected && user.effects[PBEffects::Outrage] == 0
      user.effects[PBEffects::Outrage] = 2 + @battle.pbRandom(2)
      user.currentMove = @id
    end
    if user.effects[PBEffects::Outrage] > 0
      user.effects[PBEffects::Outrage] -= 1
      if user.effects[PBEffects::Outrage] == 0 && user.pbCanConfuseSelf?(false)
        user.pbConfuse(_INTL("{1} became confused due to fatigue!", user.pbThis))
      end
    end
  end
end

#===============================================================================
# Lower Defences + Confuse Chance
#===============================================================================
 
class Battle::Move::LowerDefenses2Confuse < Battle::Move::TargetMultiStatDownMove
  def initialize(battle, move)
    super
    @statDown = [:DEFENSE, 1, :SPECIAL_DEFENSE, 1]
  end
  
  ## Add in a clause that may confuse target
    def pbEffectAgainstTarget(user, target)
      super
      # 30% chance to confuse
      if rand(1..10) <= 3
        target.pbConfuse if target.pbCanConfuse?(user, false, self)
      end
    end  
end
#pbEffectAgainstTarget(user, target)
#===================================================================
# Lower Speed + Confuse Chance
#===============================================================================
class Battle::Move::LowerTargetSpeed2Confuse < Battle::Move::TargetMultiStatDownMove
  def initialize(battle, move)
    super
    @statDown = [:SPEED, 2]
  end
  
  ## Add in a clause that may confuse target
    def pbEffectAgainstTarget(user, target)
      super
      # 30% chance to confuse
      if rand(1..10) <= 3
        target.pbConfuse if target.pbCanConfuse?(user, false, self)
      end
    end  
end    


### PB CHANGEFORM ###
  def pbChangeForm(newForm, msg)
    #return if fainted? || @effects[PBEffects::Transform] || @form == newForm
    return if @form == newForm
    
    oldForm = @form
    oldDmg = @totalhp - @hp
    self.form = newForm
    pbUpdate(true)
    @hp = @totalhp - oldDmg
    @effects[PBEffects::WeightChange] = 0 if Settings::MECHANICS_GENERATION >= 6
    @battle.scene.pbChangePokemon(self, @pokemon)
    @battle.scene.pbRefreshOne(@index)
    @battle.pbDisplay(msg) if msg && msg != ""
    PBDebug.log("[Form changed] #{pbThis} changed from form #{oldForm} to form #{newForm}")
    @battle.pbSetSeen(self)
  end
  
###
#===============================================================================
# Overeat - Increase Defenses, Lower Speed
#===============================================================================
class Battle::Move::RaiseUserDefSpD1LowerSpeed1 < Battle::Move::MultiStatUpMove
  
  def initialize(battle, move)
    super
    @statUp   = [:DEFENSE, 1, :SPECIAL_DEFENSE, 1]
    @statDown = [:SPEED, 1]
  end

  ## Add in transformation
  #def pbEndOfMoveUsageEffect(user, targets, numHits, switchedBattlers)
  #  super
  #  if user.isSpecies?(:EDGARMON)
      #newForm = 1
      #user.pbChangeForm(newForm, _INTL("{1} transformed into his CHONK form!", user.pbThis))
      #user.pbChangeForm(:EDGARMON_1)
      #@battle.pbDisplay(_INTL("{1} transformed into his CHONK form!", user.pbThis))
      #pbChangeForm(newForm, _INTL("{1} transformed into his CHONK form!", user.pbThis))
  #  end
  #end
  
end
  
#===============================================================================
# Chance to Paralyze, Poison or Sleeps the target. (MossParPsnSleep)
#===============================================================================
class Battle::Move::MossParPsnSleep < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    if target.poisoned? || target.asleep? || target.paralyzed?
       (target.effects[PBEffects::Substitute] == 0 || ignoresSubstitute?(user))
      baseDmg *= 1.5
    end
    return baseDmg
  end
  
  def pbAdditionalEffect(user, target)
    return if target.damageState.substitute
    case @battle.pbRandom(3)
    when 0 then target.pbParalyze if target.pbCanParalyze?(user, false, self)
    when 1 then target.pbPoison if target.pbCanPoison?(user, false, self)
    when 2 then target.pbSleep if target.pbCanSleep?(user, false, self)
    end
  end
end

#===============================================================================
# RECOIL + Paralyze
#===============================================================================
class Battle::Move::RecoilThirdParalyzeChance < Battle::Move::RecoilMove
  
  def pbRecoilDamage(user, target)
    return (target.damageState.totalHPLost / 3.0).round
  end
  
  def pbAdditionalEffect(user, target)
    return if target.damageState.substitute
    target.pbParalyze if target.pbCanParalyze?(user, false, self)
  end
end

#===============================================================================
# Paralyze, Poison, Sleep Chance (StrangePowder)
#===============================================================================
class Battle::Move::ParalyzePoisonSleepTargetStatus < Battle::Move
  
    def pbEffectAgainstTarget(user, target)
      return if target.damageState.substitute
      case @battle.pbRandom(3)
      when 0 then target.pbParalyze if !target.paralyzed?
      when 1 then target.pbPoison if !target.poisoned?
      when 2 then target.pbSleep if !target.asleep?
      end
    end
end

#===============================================================================
# Hits 3 times. + Status chance (MossPlume)
# An accuracy check is performed for each hit.
#===============================================================================
class Battle::Move::MossPlume < Battle::Move
  def multiHitMove?;            return true; end
  def pbNumHits(user, targets); return 3;    end

  def successCheckPerHit?
    return @accCheckPerHit
  end

  def pbBaseDamage(baseDmg, user, target)
    if target.poisoned? || target.asleep? || target.paralyzed?
       (target.effects[PBEffects::Substitute] == 0 || ignoresSubstitute?(user))
      baseDmg *= 1.5
    end
    return baseDmg
  end
  
  def pbOnStartUse(user, targets)
    @calcBaseDmg = 0
    @accCheckPerHit = !user.hasActiveAbility?(:SKILLLINK)
  end

  def pbEffectAfterAllHits(user, target)
    if !target.damageState.fainted && !target.damageState.substitute
    # 30% chance for status
      case @battle.pbRandom(10)
        when 0 then target.pbParalyze if target.pbCanParalyze?(user, false, self)
        when 1 then target.pbPoison if target.pbCanPoison?(user, false, self)
        when 2 then target.pbSleep if target.pbCanSleep?(user, false, self)
      end
    end
  end
  
end

#===============================================================================
# DREAMWEAVE
#===============================================================================
class Battle::Move::Dreamweave < Battle::Move
  
  def pbBaseDamage(baseDmg, user, target)
    if !target.asleep?
      target.pbSleep if target.pbCanSleep?(user, false, self)
       baseDmg = 0
    else
       baseDmg *= 1
    end
    return baseDmg
  end
  
  def pbEffectAgainstTarget(user, target)
    target.pbSleep if target.pbCanSleep?(user, false, self)  
  end
end

#===============================================================================
# Foilage Feast (Grass Move, Super Effective vs Grass)
#===============================================================================
class Battle::Move::SEvsGrass < Battle::Move
  def pbCalcTypeModSingle(moveType, defType, user, target)
    return Effectiveness::SUPER_EFFECTIVE_MULTIPLIER if defType == :GRASS
    return super
  end
  
  def healingMove?; return Settings::MECHANICS_GENERATION >= 6; end

  def pbEffectAgainstTarget(user, target)
    return if target.damageState.hpLost <= 0
    hpGain = (target.damageState.hpLost / 2.0).round
    user.pbRecoverHPFromDrain(hpGain, target)
  end

end

#===============================================================================
# Cures user of freeze, burn, poison and paralysis. (Prep Meds)
#===============================================================================
class Battle::Move::CureUserRaiseSpDef1 < Battle::Move::StatUpMove
  def canSnatch?; return true; end

 # def pbMoveFailed?(user, targets)
 #   if ![:BURN, :POISON, :PARALYSIS, :FROZEN].include?(user.status)
 #     @battle.pbDisplay(_INTL("But it failed!"))
 #     return true
 #   end
 #   return false
 # end
  def initialize(battle, move)
    super
    @statUp = [:SPECIAL_DEFENSE, 1]
    #@statDown = [:SPEED, 1]
  end

  def pbEffectGeneral(user)
    old_status = user.status
    user.pbCureStatus(false)
    case old_status
    when :BURN
      @battle.pbDisplay(_INTL("{1} healed its burn!", user.pbThis))
    when :POISON
      @battle.pbDisplay(_INTL("{1} cured its poisoning!", user.pbThis))
    when :PARALYSIS
      @battle.pbDisplay(_INTL("{1} cured its paralysis!", user.pbThis))
    when :FROZEN
      @battle.pbDisplay(_INTL("{1} cured its freeze!", user.pbThis))
    end
  end
end


#===============================================================================
# Increases the user's Attack, Defense, Speed, Special Attack and Special Defense
# by 1 stage each. May cause sleep.
#===============================================================================
class Battle::Move::RaiseAllStatsSleep < Battle::Move::MultiStatUpMove
    def initialize(battle, move)
      super
      @statUp = [:ATTACK, 1, :DEFENSE, 1, :SPECIAL_ATTACK, 1, :SPECIAL_DEFENSE, 1, :SPEED, 1]
    end
  
  def pbEffectGeneral(user)
    if rand(1..3) == 1
      user.pbSleepSelf(_INTL("{1} fell asleep dreaming about Disney!", user.pbThis), 2)
    end
  end
  
end

#===============================================================================
# Bowling Move - Attracts the target - regardless of gender. (Attract)
#===============================================================================
class Battle::Move::AttractTargetGenderless < Battle::Move
  def ignoresSubstitute?(user); return true; end
  def canMagicCoat?; return true; end

  def pbFailsAgainstTarget?(user, target, show_message)
    puts target.effects[PBEffects::Attract]
    return false if damagingMove?
    return true if target.effects[PBEffects::Attract] == 0
    return false
  end

  def pbEffectAgainstTarget(user, target)  
    if target.effects[PBEffects::Attract] == 0
      @battle.pbDisplay(_INTL("{1} is unaffected!", pbThis)) if showMessages
      return false
    else
      target.pbAttract(user)
    end
  end

end

#===============================================================================
# Soccer Training - Chance to Raise 1-3 Physical Stats
#===============================================================================
class Battle::Move::RaisePhysicalChance < Battle::Move

  def pbEffectGeneral(user)
    stats = ["ATTACK","DEFENSE","SPEED"]
    first_stat = stats.sample
    stat1 = first_stat.to_sym

    if user.pbCanRaiseStatStage?(stat1, user, self)
      user.pbRaiseStatStage(stat1, 1, user)
    end
    
    if rand(1..2) == 2
      ## Take first stat from frame
      remaining_stats = stats - [first_stat]
      ## Select a second random stat
      second_stat = remaining_stats.sample
      stat2 = second_stat.to_sym
      
      if user.pbCanRaiseStatStage?(stat2, user, self)
        user.pbRaiseStatStage(stat2, 1, user)
      end
      
      if rand(1..4) == 4
        ## Take second stat from frame
        remaining_stats = remaining_stats - [second_stat]
        ## Select the final stat
        third_stat = remaining_stats.sample
        stat3 = third_stat.to_sym
        
      if user.pbCanRaiseStatStage?(stat3, user, self)
        user.pbRaiseStatStage(stat3, 1, user)
      end
      
        stat_inc = [stat1, 1, stat2, 1, stat3, 1]
      else
        stat_inc = [stat1, 1, stat2, 1]
      end
    else
      stat_inc = [stat1, 1]
    end
    
    #@statUp = stat_inc

  end
end

#===============================================================================
# Edgar - Sleepy Kick (Usable When Asleep)
#===============================================================================
class Battle::Move::SleepyKick < Battle::Move
  def usableWhenAsleep?; return true; end
   
  def multiHitMove?; return true; end

  def pbNumHits(user, targets)
    hitChances = [
      1, 1,
      2, 2, 2, 2,
      3, 3, 3, 3
    ]
    r = @battle.pbRandom(hitChances.length)
    r = hitChances.length - 1 if user.hasActiveAbility?(:SKILLLINK)
    return hitChances[r]
  end
     
  def pbBaseDamage(baseDmg, user, target)
    if target.asleep? &&
       (target.effects[PBEffects::Substitute] == 0 || ignoresSubstitute?(user))
      baseDmg *= 2
    end
    if user.asleep?
      baseDmg *= 2
    end
    return baseDmg
  end

  def pbEffectAfterAllHits(user, target)
    return if target.fainted?
    return if target.damageState.unaffected || target.damageState.substitute
    return if target.status != :SLEEP
    target.pbCureStatus
  end
  
end

#===============================================================================
# Anna - Pixel Blast - Hit 3 Times, may paralyze
#===============================================================================
class Battle::Move::HitThreeTimesParalyzeTarget < Battle::Move
  def multiHitMove?;            return true; end
  def pbNumHits(user, targets); return 3;    end

  def successCheckPerHit?
    return @accCheckPerHit
  end
  
  def pbAdditionalEffect(user, target)
    return if target.damageState.substitute
    target.pbParalyze(user) if target.pbCanParalyze?(user, false, self)
  end

end

#===============================================================================
# For 5 rounds, lowers power of attacks against the user's side. Fails if
# weather is not hail. (Aurora Veil)
#===============================================================================
class Battle::Move::StartWeakenDamageAgainstUserSide < Battle::Move
  def canSnatch?; return true; end

  def pbMoveFailed?(user, targets)
    #if user.effectiveWeather != :Hail
    #  @battle.pbDisplay(_INTL("But it failed!"))
    #  return true
    #end
    if user.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.pbOwnSide.effects[PBEffects::AuroraVeil] = 5
    user.pbOwnSide.effects[PBEffects::AuroraVeil] = 8 if user.hasActiveItem?(:LIGHTCLAY)
    @battle.pbDisplay(_INTL("{1} made {2} stronger against physical and special moves!",
                            @name, user.pbTeam(true)))
  end
end

#===============================================================================
# Create Grassy Terrain, Boost User's defences
#===============================================================================
class Battle::Move::StartGrassyTerrainBoostDefSpD < Battle::Move::MultiStatUpMove
  def pbMoveFailed?(user, targets)
    if @battle.field.terrain == :Grassy
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
  
  def initialize(battle, move)
      super
      @statUp = [:DEFENSE, 1, :SPECIAL_DEFENSE, 1]
  end

  def pbEffectGeneral(user)
    @battle.pbStartTerrain(user, :Grassy)
  end

end

#=====================
# Glowing Routine
#=====================
class Battle::Move::GlowingRoutine < Battle::Move

  def pbEffectGeneral(user)
    if user.pbCanRaiseStatStage?(:SPECIAL_DEFENSE, user, self)
      user.pbRaiseStatStage(:SPECIAL_DEFENSE, 2, user)
    end
	  
  user.effects[PBEffects::GlowingRoutine] = 4
	@battle.pbDisplay(_INTL("{1} applied their glowing routine and became immune to status moves!", user.pbThis))
  end
end

#=====================
# Peanut Crash - Recoil if no glowing routine, can confuse target
#=====================
class Battle::Move::PeanutCrash < Battle::Move::RecoilMove
  def pbRecoilDamage(user, target)
    if user.effects[PBEffects::GlowingRoutine] == 0
      return (target.damageState.totalHPLost / 3.0).round
    else
      return 0
    end
  end

  def pbAdditionalEffect(user, target)
    return if target.damageState.substitute
    target.pbConfuse(user) if target.pbCanConfuse?(user, false, self)
  end
end


#===============================================================================
# Waifu Charm - Decreases stats, chance to attract
#===============================================================================
class Battle::Move::WaifuCharm < Battle::Move::TargetMultiStatDownMove
  def initialize(battle, move)
    super
    @statDown = [:ATTACK, 1, :SPECIAL_ATTACK, 1]
  end
  
  def ignoresSubstitute?(user); return true; end
  def canMagicCoat?; return true; end

 # def pbFailsAgainstTarget?(user, target, show_message)
 #   return false if damagingMove?
 #   return true if !target.pbCanAttract?(user, show_message)
 #   return false
 # end

  def pbEffectAgainstTarget(user, target)
    if target.pbCanLowerStatStage?(:ATTACK, target, self)
      target.pbLowerStatStage(:ATTACK, 1, target)
    end
    if target.pbCanLowerStatStage?(:SPECIAL_ATTACK, target, self)
      target.pbLowerStatStage(:SPECIAL_ATTACK, 1, target)
    end
    
    if rand(1..100) <= 40
      target.pbAttract(user)
    end
    #return if damagingMove?
    #target.pbAttract(user)
  end

  #def pbAdditionalEffect(user, target)
    #target.pbAttract(user)
    #return if target.damageState.substitute
    #target.pbAttract(user) if target.pbCanAttract?(user, false)
  #end
  
end

#===============================================================================
# Final Rehearsal - Stat increase Doubled if used on first turn of battle
#===============================================================================
class Battle::Move::FinalRehearsal < Battle::Move

  def pbEffectGeneral(user)
    if user.turnCount == 1
      increase = 2
    else
      increase = 1
    end
    
    if user.pbCanRaiseStatStage?(:ATTACK, user, self)
      user.pbRaiseStatStage(:ATTACK, increase, user)
    end
    if user.pbCanRaiseStatStage?(:SPEED, user, self)
      user.pbRaiseStatStage(:SPEED, increase, user)
    end
  end
end

#===============================================================================
# User locked into move for 3 turns. Increasing in power with each hit.
#===============================================================================
class Battle::Move::MultiTurnAttackIncreasingPower < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    dmg = 60  # Default damage value
    if user.effects[PBEffects::Outrage] == 0
      dmg = baseDmg * 1.0 # 60
    elsif user.effects[PBEffects::Outrage] == 2
      dmg = baseDmg * 1.5 # 90
    elsif user.effects[PBEffects::Outrage] == 1
      dmg = baseDmg * 2 # 120
    end
    puts "Return dmg"
    puts dmg
    return dmg
  end

  def pbEffectAfterAllHits(user, target)
    if !target.damageState.unaffected && user.effects[PBEffects::Outrage] == 0
      user.effects[PBEffects::Outrage] = 2 + @battle.pbRandom(2)
      user.currentMove = @id
    end
    
    if user.effects[PBEffects::Outrage] > 0
      user.effects[PBEffects::Outrage] -= 1
    end
  end
end
