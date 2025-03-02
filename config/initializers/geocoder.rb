# frozen_string_literal: true

Geocoder.configure(
  # street address geocoding service (default :nominatim)
  lookup: :google,

  # to use an API key:
  api_key: ENV['GOOGLE_MAPS_API_KEY'],
  use_https: true,

  # geocoding service request timeout, in seconds (default 3):
  timeout: 5
)
