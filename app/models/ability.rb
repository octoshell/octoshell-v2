# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)

    can do |action, subject_class, subject|
      if !user
        false
      elsif str_or_symbol?(subject_class)
        user.permissions.where(action: aliases_for_action(action), subject_class: subject, available: true).exists?
      else
        user.permissions.where(action: aliases_for_action(action), available: true).any? do |permission|
          permission.subject_class == subject_class.to_s  &&
            (subject.nil? || permission.subject_id.nil? || permission.subject_id == subject.id)
        end
      end
    end

    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end

  def str_or_symbol?(arg)
    [Symbol, String].include? arg
  end

end
