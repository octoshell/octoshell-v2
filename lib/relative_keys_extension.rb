if !defined?(Rails) || Rails.env.development?
  require 'active_support/all'
  module RelativeKeysExtension
    extend ActiveSupport::Concern
    def path_root(path, roots)
      new_roots = roots.map do |p|
        File.expand_path(p) + File::SEPARATOR
      end
      roots_with_star, new_roots = new_roots.partition { |root| root.include? '*' }
      roots_with_star.each do |root|
        new_roots += Dir.glob(root)
      end
      new_roots.sort.reverse_each.detect do |root|
        path.start_with?(root)
      end
    end
  end
  module I18n::Tasks::Scanners
    [RubyAstScanner, PatternScanner, PatternMapper].each do |scanner|
      scanner.prepend RelativeKeysExtension
    end
  end
end
