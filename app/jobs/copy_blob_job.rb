class CopyBlobJob < ApplicationJob
  queue_as :default

  def perform(blob, source_service_name, destination_service_name)
    source_service = ActiveStorage::Blob.services.fetch(source_service_name.to_sym)
    destination_service = ActiveStorage::Blob.services.fetch(destination_service_name.to_sym)

    if source_service.exist?(blob.key)
      source_service.open(blob.key, checksum: blob.checksum) do |file|
        destination_service.upload(blob.key, file, checksum: blob.checksum)
        Rails.logger.info "Copied id:#{blob.id}, key:#{blob.key}"
      end
      blob.update_columns(service_name: destination_service.name)
    else
      msg = "Could not find id:#{blob.id}, key:#{blob.key}"
      Rails.logger.fatal msg
      raise msg
    end
  end
end
