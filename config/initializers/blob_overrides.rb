# config/initializers/blob_overrides.rb

Rails.application.config.to_prepare do
  module ActiveStorage::Blob::Representable

    # Returns true if the blob is variable or previewable AND it exists in the storage location.
    def representable?
      service.exist?(key) && (variable? || previewable?)
    end
  end
end
