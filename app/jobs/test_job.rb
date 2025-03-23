class TestJob < ApplicationJob
  queue_as :default

  def perform(*args)
    output = "TestJob:  #{Time.now}  #{self.serialize}"
    puts output unless Rails.env.test?
    output
  end
end
