task fetch_inbox: :environment do
  ReceiveEmails::IMAPConnector.new.call
end
