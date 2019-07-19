module ApplicationHelper
  def flash_message(type,msg)
    flash[type] ||= []
    flash[type] << msg
  end

  def octo_url_for(*args)
    engine = args.last.class.to_s.split('::').first.underscore
    eval(engine).url_for(args)
  end
end
