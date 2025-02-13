class SetupPreview
  def self.previewing_email(message)
    message.attachments.inline['looseendslogo.png'] =
      Rails.root.join('app', 'assets', 'images', 'looseendslogo.png').read
  end
end
