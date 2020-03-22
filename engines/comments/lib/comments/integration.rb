module Comments

  def self.render_attachments(attachable, attachment_type)
    r = AttRenderer.new(attachment_type.to_s, current_user,attachable)
    r.render
  end

  def self.render_all_attachments
    r = AttRenderer.new(attachment_type.to_s, current_user)
    r.render
  end
end
