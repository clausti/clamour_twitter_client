require 'addressable/uri'
require 'rest-client'
require 'nokogiri'
require 'json'

#take current location in coordinates
#find nearby ice cream shops (1 mile) "nearby search" at lat long coords

# https://maps.googleapis.com/maps/api/place/nearbysearch/output?parameters

puts "Let's find ice cream! \nWhat is your current address?"
address = gets.chomp
#address = "1061 Market Street, San Francisco, CA"

#address for get request to convert street addy to lat,lng
get_location_url = Addressable::URI.new(
   :scheme => "https",
   :host => "maps.googleapis.com",
   :path => "maps/api/geocode/json",
   :query_values => { :address => address,
                      :sensor => false }
 ).to_s

location_as_json = RestClient.get(get_location_url)
address_as_object = JSON.parse(location_as_json)

location_hash = address_as_object["results"][0]["geometry"]["location"]
location_lat_lng = "#{location_hash["lat"]},#{location_hash["lng"]}"


# https://maps.googleapis.com/maps/api/place/nearbysearch/output?parameters

api_key = "AIzaSyCbuih5yqovBZbjn7ppwuUlEumyFpkZSTg"

#address for get request for nearby places search
get_places_url = Addressable::URI.new(
   :scheme => "https",
   :host => "maps.googleapis.com",
   :path => "maps/api/place/nearbysearch/json",
   :query_values => { :key => api_key,
                      :location => location_lat_lng,
                      # :radius => 1600, don't use if rankby specified
                      :sensor => false,
                      :keyword => "ice cream",
                      :types => "food",
                      :rankby => "distance" }
 ).to_s

places_as_json = RestClient.get(get_places_url)
places_as_object = JSON.parse(places_as_json)
closest_5_places = places_as_object["results"][0..4]

#display menu of top 5 by distance
puts "\nHere's what's closest:"
closest_5_places.each_with_index do |place, index|
  puts "#{index + 1}. #{place["name"]}, rated: #{place["rating"]}"
end
puts "\nWhere do you want to go?"
selection = gets.chomp.to_i - 1 #index

selection = 0
selected_place = closest_5_places[selection]
selected_place_hash = selected_place["geometry"]["location"]
selected_place_lat_lng = "#{selected_place_hash["lat"]},#{selected_place_hash["lng"]}"

#get directions to specified place by index

get_directions_url = Addressable::URI.new(
   :scheme => "https",
   :host => "maps.googleapis.com",
   :path => "maps/api/directions/json",
   :query_values => { :origin => location_lat_lng,
                      :destination => selected_place_lat_lng,
                      :sensor => false,
                      :mode => "walking" }
 ).to_s

#return directions to console
directions_as_json = RestClient.get(get_directions_url)
directions_as_object = JSON.parse(directions_as_json)

walking_directions = directions_as_object["routes"][0]["legs"][0]

puts "Start from: #{address}"
walking_directions["steps"].each_with_index do |step, index|
  puts "  #{index+1}. #{Nokogiri::HTML(step["html_instructions"]).text} #{step["distance"]["text"]}"
end
puts "End at: #{walking_directions["end_address"]} Total distance: #{walking_directions["distance"]["text"]}"
puts "\nEnjoy your ice cream!"





