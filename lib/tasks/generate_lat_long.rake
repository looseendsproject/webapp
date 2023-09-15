# lib/tasks/generate_lat_long.rake

namespace :generate_lat_long do
  desc 'Generate latitude and longitude for all finishers'

  task :update => :environment do
    finishers = Finisher.all

    finishers.each do |finisher|
      result = finisher.geocode
        if result
          finisher.save
          puts "SUCCESS >> Finisher with id: #{finisher.id}. Coordinates: #{result}."
        elsif finisher.latitude && finisher.longitude
          finisher.latitude = nil
          finisher.longitude = nil
          finisher.save
          puts "FAILURE >> Finisher with id: #{finisher.id}."
        else
          puts "FAILURE >> Finisher with id: #{finisher.id}."
        end      
    end
  end
end
