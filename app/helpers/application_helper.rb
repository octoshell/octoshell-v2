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
    render 'options/fields', f: f
  end

  def show_options(record)
    res = true
    res = yield if block_given?
    options = record.options.select { |o| !o.admin || res }
    render partial: 'options/index', locals: { options: options }
  end

  def custom_helper(role, helper, f, prefix = '', options = {}, html_options = {})
    octo_config = Octoface::OctoConfig.find_by_role(role)
    return nil unless octo_config

    octo_config.mod.const_get('BootstrapFormHelper')
               .try(helper, f, prefix, options, html_options)
    # method.call(prefix, label)
  end
end
