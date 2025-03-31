# config/initializers/blob_overrides.rb

Rails.application.config.to_prepare do
  module ActiveStorage::Blob::Representable

    # Avoid throwing 500s on missing storage objects. The default
    # representable? doesn't confirm that the object exists on the
    # storage service before trying to download it.
    def representable?

      # The blob has to be either variable or previewable, but
      # we still don't know if it exists on the storage service.
      return false unless (variable? || previewable?)

      # Sometimes in dev, you might be using a copy of real data
      # in which case the active_storage_blobs.service_name points to
      # the live storage service.  If you don't have the storage service
      # API credentials, you will be frustrated.
      if Rails.env.development? && (ENV['AWS_ACCESS_KEY_ID'].blank? ||
          ENV['AWS_SECRET_ACCESS_KEY'].blank?)
        return true
      else

        # But, if you do have the storage service credentials,
        # make sure the object is there before you try to download it.
        service.exist?(key)
      end
    end

  end
end
