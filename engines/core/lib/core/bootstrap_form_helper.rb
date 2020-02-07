module Core
  module BootstrapFormHelper
    def self.project_kind_id_eq(f, prefix = '', options = {}, html_options = {})
      options[:label] ||= Core::ProjectKind.model_name.human
      options[:include_blank] ||= true
      f.collection_select(prefix + 'kind_id_eq', Core::ProjectKind.all, :id, :name, options, html_options)
    end
  end
end
