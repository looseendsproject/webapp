class TestJob < ApplicationJob
  queue_as :default

  def perform(*args)
    output = "TestJob:  #{Time.now}  #{self.serialize}"
    puts output
    output
  end
end
