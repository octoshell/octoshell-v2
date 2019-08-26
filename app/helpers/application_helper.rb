module ApplicationHelper
  def flash_message(type,msg)
    flash[type] ||= []
    flash[type] << msg
  end

  def octo_url_for(*args)
    array = args.last.class.to_s.split('::')
    engine = if array.length == 1
               main_app
             else
               eval(args.last.class.to_s.split('::').first.underscore)
             end
    engine.url_for(args)
  end

  def form_for_options(f)
    render partial: 'options/fields', locals: { f: f }
  end
end
