# frozen_string_literal: true

namespace :dev do

  ### Dev convenience tools

  # You gotta have the prod AWS creds in your .env
  #
  desc "Copy most recent Message email_source attachments to development or staging S3 bucket"
  task fetch_email_source: [:environment] do |_t|
    exit if ENV["RAILS_ENV_DISPLAY"] == "production" # DO NOT DO THIS IN PROD

    LIMIT = 100

    messages = Message.where(channel: "inbound").order(created_at: :desc).limit(LIMIT)
    messages.each do |message|
      CopyBlobJob.perform_now(message.email_source.blob, "aws_s3_production", "aws_s3")
    end
  end

end
