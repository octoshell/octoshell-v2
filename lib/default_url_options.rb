module DefaultUrlOptions
  PORT = ENV.fetch('SERVER_PORT', nil)
  def default_url_options(_options = {})
    { only_path: false, port: PORT.to_i }
  end
end
if DefaultUrlOptions::PORT
	puts "Default port is set to port #{DefaultUrlOptions::PORT}"
	ActionController::Base.prepend(DefaultUrlOptions)
end
