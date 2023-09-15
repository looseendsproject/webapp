# lib/tasks/generate_lat_long.rake

namespace :generate_lat_long do
  desc 'Generate latitude and longitude for all finishers'

  task :update => :environment do
    finishers = Finisher.all

    # iterate through each finisher and attempt to geocode them...
    finishers.each do |finisher|
      result = finisher.geocode
      if result
        # ...if successful, save the finisher
        finisher.save
        puts "SUCCESS >> Finisher with id: #{finisher.id}. Coordinates: #{result}."
      elsif finisher.latitude && finisher.longitude
        # ...if unsuccessful and the finisher previously had a lat and long, overwrite them with nil
        puts "FAILURE >> Finisher with id: #{finisher.id}. Removing coordinates: #{finisher.latitude}, #{finisher.longitude}"
        finisher.latitude = nil
        finisher.longitude = nil
        finisher.save
      else
        # ...else, do nothing except log the failure
        puts "FAILURE >> Finisher with id: #{finisher.id}."
      end
      # per Geocoder documentation, limiting request rate to once per second 
      # https://github.com/alexreisner/geocoder/blob/master/README_API_GUIDE.md
      sleep(1) 
    end
  end
end
