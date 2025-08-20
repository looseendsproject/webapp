# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "info@looseendsproject.org"
  layout "mailer"

  before_action :add_logo!, :create_message_record
  after_deliver :record_delivery

  # Any actions in any mailers that inherit from self
  # must call "@message.set_sgid!" if they want a
  # magic link. Pass `expires_in: 1.second` to get an
  # expired link
  #
  def test
    @message.set_sgid!(expires_in: params[:expires_in], single_use: false)
    mail(to: @resource.user.email, subject: "Looseends ApplicationMailer.test")
  end

  def error(to: to)
    mail(to: to, subject: "[Bounce] Email to Loose Ends Project too big")
  end

  private

    def add_logo!
      attachments.inline['looseendslogo.png'] =
        Rails.root.join('app', 'assets', 'images', 'looseendslogo.png').read
    end

    # Create the Message record before action so we get an ID and therefore
    # can issue an SGID that the mailer template needs for the
    # magic link. (TODO: We should catch mail errors and destroy orphan
    # Messages.)
    #
    # Devise controllers do not pass params, so don't log those.  Also,
    # don't log mail previews using User.fake (not persisted)
    #
    def create_message_record
      if params.present?
        @resource = params[:resource]
        @message = @resource.messages.create(channel: "outbound")
      end
    end

    # We only get the Mail::Message body after delivery.  Here's
    # also where we set the link_action for the mailer action
    # that was called.
    #
    def record_delivery
      return false unless @message.present? # skip Devise emails
      @message.channel = "outbound"
      @message.stash_headers(message)
      @message.email_source.attach(io: StringIO.new(message.to_s),
        filename: "source.eml", content_type: "text/plain")
      @message.save!
    end
end
