source_service = ActiveStorage::Blob.services.fetch(:amazon)
destination_service = ActiveStorage::Blob.services.fetch(:aws_s3)

puts "Starting job"

ActiveStorage::Blob.where(service_name: source_service.name).each do |blob|
  print "Working on id:#{blob.id}, key:#{blob.key}.  "

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

puts "Job finished"