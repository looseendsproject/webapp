# frozen_string_literal: true

namespace :verify do
  desc "solid_queue"
  task solid_queue: [:environment] do |_t|
    10.times do
      TestJob.perform_later
    end
  end
end
