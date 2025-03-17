# frozen_string_literal: true

namespace :blobs do
  desc "copy all blobs from @swards S3 to LEP S3"
  task copy_all: [:environment] do |_t|
    source_service = ActiveStorage::Blob.services.fetch(:amazon)
    destination_service = ActiveStorage::Blob.services.fetch(:aws_s3)

    jobs = ActiveStorage::Blob.where(service_name: source_service.name).map do |blob|
      CopyBlobJob.new(blob, source_service.name, destination_service.name)
    end
    ActiveJob.perform_all_later(jobs)
  end

  desc "copy one blob for testing"
  task copy_first: [:environment] do |_t|
    source_service = ActiveStorage::Blob.services.fetch(:amazon)
    destination_service = ActiveStorage::Blob.services.fetch(:aws_s3)

    blob = ActiveStorage::Blob.where(service_name: source_service.name).first
    CopyBlobJob.perform_later(blob, source_service.name, destination_service.name)
  end
end
