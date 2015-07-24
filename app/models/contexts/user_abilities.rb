module UserAbilities
  def may?(*args)
    ability.may? *args
  end

  def maynot?(*args)
    ability.maynot? *args
  end

  # Адский хак! Переделать на User -> Groups -> GroupAbilities -> Abilities
  def abilities
    user_abilities = Ability.where(group_id: group_ids).where(available: true)
    user_abs_definitions = user_abilities.map(&:to_definition)
    default_abilities = Ability.default.select do |ability|
      !user_abs_definitions.include?(ability.to_definition)
    end
    user_abilities | default_abilities
  end

  def ability
    @ability ||= begin
      mm = MayMay::Ability.new(self)
      abilities.each do |ability|
        method = ability.available ? :may : :maynot
        mm.send method, ability.action_name, ability.subject_name
      end
      mm
    end
  end
end
