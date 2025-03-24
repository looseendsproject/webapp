# staging:  send to "inbound@parse-staging.looseendsproject.org"
# production: "inbound@parse.looseendsproject.org"

class ApplicationMailbox < ActionMailbox::Base
  routing :all => :forwards
end
