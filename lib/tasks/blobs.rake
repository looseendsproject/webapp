# frozen_string_literal: true

namespace :blobs do
  desc "copy all blobs from @swards S3 to LEP S3"
  task copy_all: [:environment] do |_t|
    CHUNK_SIZE = 100.0

    source_service = ActiveStorage::Blob.services.fetch(:amazon)
    destination_service = ActiveStorage::Blob.services.fetch(:aws_s3)

    all_blobs = ActiveStorage::Blob.where(service_name: source_service.name)
    record_count = all_blobs.count
    total_passes = (record_count / CHUNK_SIZE).ceil

    puts "Enqueueing #{record_count} blobs.  #{total_passes} passes required."

    passes_complete = 0
    while passes_complete < total_passes do
      blobs = all_blobs.limit(CHUNK_SIZE).offset(passes_complete * CHUNK_SIZE)

      jobs = blobs.map do |blob|
        CopyBlobJob.new(blob, source_service.name, destination_service.name)
      end
      ActiveJob.perform_all_later(jobs)
      passes_complete += 1

      puts "pass #{passes_complete} complete"
    end

    puts "Done enqueueing blobs"
  end

  desc "copy one blob for testing"
  task copy_first: [:environment] do |_t|
    source_service = ActiveStorage::Blob.services.fetch(:amazon)
    destination_service = ActiveStorage::Blob.services.fetch(:aws_s3)

    blob = ActiveStorage::Blob.where(service_name: source_service.name).first
    CopyBlobJob.perform_later(blob, source_service.name, destination_service.name)
  end
end
