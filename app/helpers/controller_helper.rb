module ControllerHelper
  def flash_message(type,msg)
    flash[type] ||= []
    flash[type] << msg
  end
  def flash_now_message(type,msg)
    flash.now[type] ||= []
    flash.now[type] << msg
  end
end
