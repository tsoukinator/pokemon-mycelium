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
        if user.pbCanParalyzeSelf?(false)
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
  # Overeat - Increase Defenses, Lower Speed
  #===============================================================================
  class Battle::Move::RaiseUserDefSpD1LowerSpeed1 < Battle::Move::MultiStatUpMove
  
    def initialize(battle, move)
      super
      @statUp   = [:DEFENSE, 1, :SPECIAL_DEFENSE, 1]
      @statDown = [:SPEED, 1]
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
      puts "Rand Factor"
      puts rand_factor
      hpLoss = [user.totalhp / rand_factor, 1].max
      puts "hpLoss"
      puts hpLoss
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
  