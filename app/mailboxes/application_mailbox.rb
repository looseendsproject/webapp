class ApplicationMailbox < ActionMailbox::Base
  routing :all => :forwards
end
