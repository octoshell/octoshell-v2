module ControllerHelper
  def flash_message(type,msg)
    flash[type] ||= []
    flash[type] << msg
  end
  def flash_now_message(type,msg)
    if flash.now[type]
      flash.now[type] = flash.now[type].push msg
    else
      flash.now[type] = [msg]
    end
    #logger.warn "FLASH-NOW = #{flash.now.inspect}"
  end
end
