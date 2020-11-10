module ApplicationHelper
  def flash_message(type,msg)
    flash[type] ||= []
    flash[type] << msg
  end

  def flash_now_message(type,msg)
    flash.now[type] ||= []
    flash.now[type] << msg
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

  def custom_helper(role, helper, *args)
    octo_config = Octoface::OctoConfig.find_by_role(role)
    return nil unless octo_config

    octo_config.mod.const_get('Interface')
                   .send(:handle_view, self, helper, *args)

     # new(self, *args)
     #           .try(helper)

    # if args[0].is_a? ActionView::Helpers::FormBuilder
    #   octo_config.mod.const_get('BootstrapFormHelper').new(self, *args)
    #              .try(helper)
    # else
    #   octo_config.send(helper, *args)
    # end
  end

  def register_hook(role, name, maps, *order)
    Octoface::Hook.find_or_initialize_hook(role, name).render(self, maps, *order)
  end
end
