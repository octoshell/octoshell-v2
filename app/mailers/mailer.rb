class Mailer < ActionMailer::Base
	def receive(email)
		puts email.inspect
	end
end
