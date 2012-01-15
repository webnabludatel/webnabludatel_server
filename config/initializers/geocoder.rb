# geocoding service (see below for supported options):
Geocoder::Configuration.lookup = :yandex

# to use an API key:
Geocoder::Configuration.api_key = "AAQ5Ek8BAAAANz_WOAIADfiEEC2cS7L4cxUsUrFxP52gws0AAAAAAAAAAABCclYqFRahy9_p1_jMaBLMEP0KUw=="

# geocoding service request timeout, in seconds (default 3):
Geocoder::Configuration.timeout = 5

# use HTTPS for geocoding service connections:
#Geocoder::Configuration.use_https = true

# language to use (for search queries and reverse geocoding):
Geocoder::Configuration.language = :ru