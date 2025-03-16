class CopyBlobJob < ApplicationJob
  queue_as :default

  def perform(blob, source_service_name, destination_service_name)
    print "Working on id:#{blob.id}, key:#{blob.key}.  "

    source_service = ActiveStorage::Blob.services.fetch(source_service_name.to_sym)
    destination_service = ActiveStorage::Blob.services.fetch(destination_service_name.to_sym)

    if source_service.exist?(blob.key)
      source_service.open(blob.key, checksum: blob.checksum) do |file|
        destination_service.upload(blob.key, file, checksum: blob.checksum)
        print "Done\n"
      end
    else
      print "Not found\n"
    end

    blob.update_columns(service_name: destination_service.name)
  end
end
