# frozen_string_literal: true

namespace :aasm do
  desc 'Generate state diagrams for all models using AASM'
  task diagrams: :environment do
    require 'aasm'
    require 'fileutils'

    I18n.locale = :ru

    output_dir = Rails.root.join('docs', 'state_machines')
    FileUtils.mkdir_p(output_dir)

    models = find_aasm_models
    puts "Found #{models.size} models with AASM"

    models.each do |model_class|
      puts "Processing #{model_class.name}..."
      generate_diagrams_for_model(model_class, output_dir)
    end

    generate_index(models, output_dir)
    puts "Diagrams saved to #{output_dir}"
  end

  desc 'List all models using AASM'
  task list: :environment do
    models = find_aasm_models
    puts "Models using AASM (#{models.size}):"
    models.each do |model|
      puts "  - #{model.name}"
    end
  end

  private

  def find_aasm_models
    require 'aasm'
    # Ensure all models are loaded
    Rails.application.eager_load!
    # Find all classes that include AASM module
    models = []
    ObjectSpace.each_object(Class) do |klass|
      next unless klass.is_a?(Class)
      next unless klass.respond_to?(:included_modules)
      next unless klass.included_modules.include?(AASM)

      # Include all models (including decorators)
      models << klass
    end
    models.uniq
  end

  def translated_state_name(model_class, state_name)
    translation = begin
      model_class.human_state_name(state_name)
    rescue StandardError
      state_name.to_s
    end
    translation.to_s.include?('Translation missing') ? state_name.to_s : translation
  end

  def translated_event_name(model_class, event_name)
    translation = begin
      model_class.human_state_event_name(event_name)
    rescue StandardError
      event_name.to_s
    end
    translation.to_s.include?('Translation missing') ? event_name.to_s : translation
  end

  def generate_diagrams_for_model(model_class, output_dir)
    # Get all state machine keys
    store = AASM::StateMachineStore[model_class.name]
    return if store.nil? || store.keys.empty?

    store.keys.each do |key|
      generate_diagram_for_state_machine(model_class, key, output_dir)
    end
  end

  def generate_diagram_for_state_machine(model_class, state_machine_key, output_dir)
    sm = model_class.aasm(state_machine_key)
    states = sm.states
    events = sm.events

    # Build transitions map
    transitions = []
    events.each do |event|
      event.transitions.each do |transition|
        froms = Array(transition.from)
        to = transition.to
        froms.each do |from|
          transitions << { from: from, to: to, event: event.name }
        end
      end
    end

    # Determine initial state
    initial_state = states.find { |s| s.options[:initial] }&.name

    # Generate filenames
    base_name = "#{model_class.name.underscore.gsub('/', '_')}_#{state_machine_key}"
    dot_file = output_dir.join("#{base_name}.dot")
    mmd_file = output_dir.join("#{base_name}.mmd")

    # Generate DOT
    dot_content = generate_dot(model_class, state_machine_key, states, events, transitions, initial_state)
    File.write(dot_file, dot_content)

    # Generate Mermaid
    mermaid_content = generate_mermaid(model_class, state_machine_key, states, events, transitions, initial_state)
    File.write(mmd_file, mermaid_content)
  end

  def generate_dot(model_class, state_machine_key, states, events, transitions, initial_state)
    lines = []
    lines << 'digraph {'
    lines << '  rankdir=LR;'
    lines << '  node [shape=oval];'
    lines << '  edge [fontsize=10];'
    lines << ''

    # States
    states.each do |state|
      label = translated_state_name(model_class, state.name)
      lines << "  #{state.name} [label=\"#{label}\"];"
    end

    # Initial state marker
    if initial_state
      lines << '  __initial [shape=point];'
      lines << "  __initial -> #{initial_state};"
    end

    # Transitions
    transitions.each do |t|
      event_label = begin
        model_class.human_state_event_name(t[:event])
      rescue StandardError
        t[:event].to_s
      end
      lines << "  #{t[:from]} -> #{t[:to]} [label=\"#{t[:event]}\\n(#{event_label})\"];"
    end

    lines << '}'
    lines.join("\n")
  end

  def generate_mermaid(model_class, state_machine_key, states, events, transitions, initial_state)
    lines = []
    lines << 'stateDiagram-v2'
    lines << '  direction LR'
    lines << ''

    # Initial state
    lines << "  [*] --> #{initial_state}" if initial_state

    # Transitions
    transitions.each do |t|
      event_label = begin
        model_class.human_state_event_name(t[:event])
      rescue StandardError
        t[:event].to_s
      end
      lines << "  #{t[:from]} --> #{t[:to]} : #{t[:event]} (#{event_label})"
    end

    lines.join("\n")
  end

  def generate_index(models, output_dir)
    index_file = output_dir.join('index.md')
    lines = []
    lines << '# State Machine Diagrams'
    lines << ''
    lines << "Generated on #{Time.current}"
    lines << ''
    lines << '## Models'
    lines << ''
    models.each do |model|
      lines << "### #{model.name}"
      store = AASM::StateMachineStore[model.name]
      next if store.nil?

      store.keys.each do |key|
        base_name = "#{model.name.underscore.gsub('/', '_')}_#{key}"
        lines << "- [#{key}](##{base_name}) ([DOT](#{base_name}.dot), [Mermaid](#{base_name}.mmd))"
      end
    end
    File.write(index_file, lines.join("\n"))
  end
end
