module Core
  module Checkable
    extend ActiveSupport::Concern
    included do
      after_create :create_ticket, unless: :checked
    end

    def current_user
      Thread.current[:user]
    end

    def print_attributes
      simple = print_simple_readable_attributes
      if self.class == Core::OrganizationDepartment
        org = "\n### #{Core::Organization.model_name.human}  \n"
        complicated = org + organization.print_attributes
      else
        complicated = print_complicated_readable_attributes
      end
      "#{simple}  \n#{complicated}"
    end

    def print_attributes_from_hash(hash)
      array = hash.map do |key, value|
        "**#{self.class.human_attribute_name(key)}**: #{value}"
      end
      array.join("  \n")
    end

    def print_simple_readable_attributes
      array = simple_readable_attributes.map { |a| [a, send(a)] }
      print_attributes_from_hash Hash[array]
    end

    def print_complicated_readable_attributes
      hash = try(:complicated_readable_attributes)
      return '' unless hash
      print_attributes_from_hash hash
    end

    def create_ticket
      return unless current_user
      name = model_name.to_s.split('::').last.downcase.pluralize
      if name == 'organizationdepartments'
        name = 'organizations'
        id = organization_id
      else
        id = self.id
      end
      url = "/core/admin/#{name}/#{id}"
      subject = I18n.t('merge.support.subject', model_name: model_name.human, to_s: to_s)
      topic = Support::Topic.find_or_create_by name: I18n.t('merge.support.theme_name')
      link_to = ActionController::Base.helpers.link_to(I18n.t('merge.show'), url)
      message = "#{print_attributes}  \n#{link_to}"
      message.gsub!('|', '\\|')
      Support::Ticket.create!(subject: subject, reporter: current_user,
                              message: message, topic: topic)
    end
  end
end
