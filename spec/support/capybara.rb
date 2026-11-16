require 'selenium-webdriver'

snap_firefox_dir = '/snap/firefox/current/usr/lib/firefox'
snap_firefox = File.join(snap_firefox_dir, 'firefox')
snap_geckodriver = File.join(snap_firefox_dir, 'geckodriver')

firefox_binary = ENV['FIREFOX_BINARY']
geckodriver = ENV['GECKODRIVER']

system_firefox = '/usr/bin/firefox'
if firefox_binary.nil? && File.executable?(snap_firefox) &&
   File.file?(system_firefox) && File.read(system_firefox).include?('firefox snap')
  firefox_binary = snap_firefox
  geckodriver ||= snap_geckodriver if File.executable?(snap_geckodriver)
end

Capybara.register_driver :headless_firefox do |app|
  options = Selenium::WebDriver::Firefox::Options.new
  options.binary = firefox_binary if firefox_binary
  options.add_argument('-headless')

  service = if geckodriver
              Selenium::WebDriver::Service.firefox(path: geckodriver)
            else
              Selenium::WebDriver::Service.firefox
            end

  Capybara::Selenium::Driver.new(app, browser: :firefox, options: options, service: service)
end

Capybara.javascript_driver = :headless_firefox
