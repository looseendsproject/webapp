namespace :import do
  desc "Import Volunteers"
  task :volunteers => [:environment] do |t|
    url = 'https://docs.google.com/spreadsheets/d/1Wax7gLCZLd9oSHGAYTMO56NcnbnYkF2rzqLGU3S3bWI/export?format=xlsx'
    xls = Roo::Spreadsheet.open(url, extension: :xlsx)
    puts xls.row(1)
  end
end
