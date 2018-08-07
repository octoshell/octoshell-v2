module MarkdownHandler
  def self.erb
    @erb ||= ActionView::Template.registered_template_handler(:erb)
  end

  def self.call(template)
    compiled_source = erb.call(template)
    "begin;#{compiled_source};end"
  end
end

ActionView::Template.register_template_handler :md, MarkdownHandler
