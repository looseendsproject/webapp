Geocoder.configure(
  # street address geocoding service (default :nominatim)
  lookup: :google,

  # to use an API key:
  api_key: Rails.application.credentials.dig(:google, :maps_api_key),
  use_https: true,

  # geocoding service request timeout, in seconds (default 3):
  timeout: 5,

  )
