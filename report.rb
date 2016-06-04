require "json"
require "csv"
require 'date'
require 'pp'

require "rest-client"

require "active_support"
require 'active_support/core_ext'

REQUEST_TYPE = "116" # potholes

services = JSON.parse(File.read("services.json"))

services.each do |s|
  data = JSON.parse(RestClient.get('https://seeclickfix.com/api/v2/issues', 
    {:params => {:page => 1, 
                 :per_page => 100,
                 :status   => "open,acknowledged,closed,archived",
                 :address => URI.escape("New Haven, CT"), 
                 :request_types => s["service_code"]}}))


  summary = Hash.new { |h,k| h[k] = { :opened => 0, :closed => 0} }

  data["issues"].each do |e|
    opened = e["created_at"] && Date.parse(e["created_at"]).monday
    closed = e["closed_at"] && Date.parse(e["closed_at"]).monday

    summary[opened][:opened] += 1 if opened
    summary[closed][:closed] += 1 if closed
  end

  summary.sort_by { |k,v| k }.each_cons(2) do |(_,a),(_,b)|
    b[:opened] += a[:opened]
    b[:closed] += a[:closed]
  end

  File.open("#{s["service_name"].parameterize}.csv", "w") do |f|
    f.puts ["Week", "Open", "Close"].to_csv

    summary.sort_by { |k,v| k }.each do |k,v| 
      f.puts [k.strftime("%Y%m%d"), v[:opened], v[:closed]].to_csv
    end
  end
end