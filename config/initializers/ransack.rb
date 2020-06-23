Ransack.configure do |config|
  config.add_predicate 'exists',
                        arel_predicate: proc { |v| v ? Ransack::Constants::NOT_EQ_ALL : Ransack::Constants::EQ_ANY },
                        compounds: false,
                        type: :boolean,
                        validator: proc { |v| Ransack::Constants::BOOLEAN_VALUES.include?(v) },
                        formatter: proc { |v| [nil].freeze }
  #config.sanitize_custom_scope_booleans = false
end
