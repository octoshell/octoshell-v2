module ReceiveEmails
  CONFIG = {
    socket_path: 'mail.sock',
    socket_permissions: 066,
    ticket_creation_allowed?: true
  }.freeze
end
