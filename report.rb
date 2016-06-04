require "json"
require "pp"
require "open-uri"
require "rest-client"

#p JSON.parse(File.read("services.json"))

# pothole: 116

puts JSON.parse(RestClient.get('https://seeclickfix.com/api/v2/issues', 
  {:params => {:page => 1, 
               :per_page => 100, 
               :address => URI.escape("New Haven, CT"), 
               :request_types => "116"}}))["issues"]