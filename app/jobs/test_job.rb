class TestJob < ApplicationJob
  queue_as :default

  def perform(*args)
    puts "TestJob:  #{Time.now}  #{self.serialize}"
  end
end
