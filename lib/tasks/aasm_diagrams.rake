# frozen_string_literal: true

namespace :aasm do
  desc 'Generate state diagrams for all models using AASM'
  task diagrams: :environment do
    require 'aasm'
    require 'fileutils'

    locales = I18n.available_locales
    locales = %i[ru en] if locales.empty?
    puts "Generating diagrams for locales: #{locales.join(', ')}"

    base_output_dir = Rails.root.join('docs', 'state_machines')
    FileUtils.mkdir_p(base_output_dir)

    models = find_aasm_models
    puts "Found #{models.size} models with AASM"

    locales.each do |locale|
      I18n.locale = locale
      puts "Processing locale: #{locale}"

      # Create directory structure: dot/locale/module and mmd/locale/module
      models.each do |model_class|
        puts "  Processing #{model_class.name}..."
        generate_diagrams_for_model(model_class, base_output_dir, locale)
      end
    end

    generate_index(models, base_output_dir, locales)
    puts "Diagrams saved to #{base_output_dir}"
  end

  desc 'List all models using AASM'
  task list: :environment do
    models = find_aasm_models
    puts "Models using AASM (#{models.size}):"
    models.each do |model|
      puts "  - #{model.name}"
    end
  end

  desc 'Generate PNG/SVG images from DOT files'
  task images: :environment do
    require 'fileutils'
    require 'open3'

    formats = ENV.fetch('FORMAT', 'png').split(',').map(&:strip)
    valid_formats = %w[png svg pdf]
    formats = formats.select { |f| valid_formats.include?(f) }
    formats = ['png'] if formats.empty?

    locale_filter = ENV['LOCALE']&.split(',')&.map(&:strip)
    overwrite = ENV['OVERWRITE'] == 'true'

    base_dir = Rails.root.join('docs', 'state_machines')
    dot_dir = base_dir.join('dot')
    image_dir = base_dir.join('images')

    unless File.exist?(dot_dir)
      puts "DOT directory not found: #{dot_dir}"
      puts "Run 'rake aasm:diagrams' first to generate DOT files."
      next
    end

    dot_files = Dir.glob(dot_dir.join('**', '*.dot')).sort
    if dot_files.empty?
      puts "No DOT files found in #{dot_dir}"
      next
    end

    puts "Found #{dot_files.size} DOT files"
    puts "Generating images in formats: #{formats.join(', ')}"
    puts "Locale filter: #{locale_filter || 'all'}"
    puts "Overwrite existing: #{overwrite}"

    dot_files.each do |dot_path|
      relative = Pathname.new(dot_path).relative_path_from(dot_dir).to_s
      # Check locale filter
      if locale_filter
        locale = relative.split('/').first
        next unless locale_filter.include?(locale)
      end

      formats.each do |format|
        image_path = image_dir.join(relative.sub(/\.dot$/, ".#{format}"))
        FileUtils.mkdir_p(File.dirname(image_path))

        if File.exist?(image_path) && !overwrite
          puts "  Skipping #{relative} -> #{format} (already exists)"
          next
        end

        puts "  Converting #{relative} -> #{format}"
        success = convert_dot_to_image(dot_path, image_path, format)
        puts "    WARNING: conversion failed for #{dot_path}" unless success
      end
    end

    puts "Images saved to #{image_dir}"
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

  def human_model_name(model_class)
    model_class.model_name.human
  rescue StandardError
    model_class.name
  end

  def safe_filename(str)
    # Replace spaces with underscores, remove slashes and colons, keep Cyrillic
    str.to_s.gsub(/\s+/, '_').gsub(%r{[/\\:]}, '')
  end

  def module_name(model_class)
    # Extract module prefix from class name (e.g., Core::Project -> core, Sessions::Report -> sessions)
    if model_class.name.include?('::')
      model_class.name.split('::').first.downcase
    else
      'global'
    end
  end

  def generate_diagrams_for_model(model_class, base_output_dir, locale)
    # Get all state machine keys
    store = AASM::StateMachineStore[model_class.name]
    return if store.nil? || store.keys.empty?

    mod = module_name(model_class)
    dot_dir = base_output_dir.join('dot', locale.to_s, mod)
    mmd_dir = base_output_dir.join('mmd', locale.to_s, mod)
    FileUtils.mkdir_p(dot_dir)
    FileUtils.mkdir_p(mmd_dir)

    store.keys.each do |key|
      generate_diagram_for_state_machine(model_class, key, dot_dir, mmd_dir)
    end
  end

  def generate_diagram_for_state_machine(model_class, state_machine_key, dot_dir, mmd_dir)
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

    # Generate filenames with human model name at the end (keep Cyrillic)
    base_name = "#{state_machine_key}_#{safe_filename(human_model_name(model_class))}"
    dot_file = dot_dir.join("#{base_name}.dot")
    mmd_file = mmd_dir.join("#{base_name}.mmd")

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
      event_label = translated_event_name(model_class, t[:event])
      lines << "  #{t[:from]} -> #{t[:to]} [label=\"#{event_label}\"];"
    end

    lines << '}'
    lines.join("\n")
  end

  def generate_mermaid(model_class, state_machine_key, states, events, transitions, initial_state)
    lines = []
    lines << 'stateDiagram-v2'
    lines << '  direction LR'
    lines << ''

    # State definitions with Russian labels
    states.each do |state|
      state_label = translated_state_name(model_class, state.name)
      # Escape double quotes in label
      safe_label = state_label.gsub('"', "'")
      lines << "  state \"#{safe_label}\" as #{state.name}"
    end
    lines << '' unless states.empty?

    # Initial state
    lines << "  [*] --> #{initial_state}" if initial_state

    # Transitions
    transitions.each do |t|
      event_label = translated_event_name(model_class, t[:event])
      lines << "  #{t[:from]} --> #{t[:to]} : #{event_label}"
    end

    lines.join("\n")
  end

  def convert_dot_to_image(dot_path, image_path, format)
    require 'shellwords'
    # Check if dot command is available
    unless system('which dot > /dev/null 2>&1')
      puts "    ERROR: Graphviz 'dot' command not found. Install Graphviz (apt-get install graphviz, brew install graphviz, etc.)"
      return false
    end

    # Determine output format flag
    format_flag = case format
                  when 'png' then '-Tpng'
                  when 'svg' then '-Tsvg'
                  when 'pdf' then '-Tpdf'
                  else '-Tpng'
                  end

    # Convert Pathname to string and shell-escape
    dot_str = dot_path.to_s
    img_str = image_path.to_s

    # Run dot command
    cmd = "dot #{format_flag} #{dot_str.shellescape} -o #{img_str.shellescape}"
    success = system(cmd)

    unless success
      # Try with -Gcharset=utf-8 for UTF-8 labels
      cmd = "dot #{format_flag} -Gcharset=utf-8 #{dot_str.shellescape} -o #{img_str.shellescape}"
      success = system(cmd)
    end

    success
  end

  def generate_index(models, base_output_dir, locales)
    index_file = base_output_dir.join('index.md')
    lines = []
    lines << '# State Machine Diagrams'
    lines << ''
    lines << "Generated on #{Time.current}"
    lines << ''
    lines << '## Locales'
    lines << ''
    locales.each do |locale|
      lines << "### #{locale}"
      lines << ''
      # Group models by module
      models_by_module = models.group_by { |m| module_name(m) }
      models_by_module.each do |mod, mod_models|
        lines << "#### Module: #{mod}"
        lines << ''
        mod_models.each do |model|
          lines << "**#{model.name}**"
          store = AASM::StateMachineStore[model.name]
          next if store.nil?

          store.keys.each do |key|
            I18n.with_locale(locale) do
              base_name = "#{key}_#{safe_filename(human_model_name(model))}"
              dot_path = "dot/#{locale}/#{mod}/#{base_name}.dot"
              mmd_path = "mmd/#{locale}/#{mod}/#{base_name}.mmd"
              lines << "- [#{key}](#{dot_path}) ([DOT](#{dot_path}), [Mermaid](#{mmd_path}))"
            end
          end
          lines << ''
        end
      end
      lines << ''
    end
    File.write(index_file, lines.join("\n"))
  end
end
