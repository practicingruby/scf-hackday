require "csv"
require "pp"
require "json"

require "active_support"
require 'active_support/core_ext'

summary = Hash.new { |h,k| h[k] = { :opened => [], :closed => []}}

CSV.foreach("scf_data.csv", :headers => true) do |r|
  next unless r["city_id"] == "3039"

  if r["created_at"]
    summary[r["request_type_id"]][:opened] << r["created_at"]
    
    if r["closed_at"]
      summary[r["request_type_id"]][:closed] << r["closed_at"]
    end
  end
end

services = JSON.parse(File.read("services.json"))

services.each do |s|
  opened = summary[s["service_code"].to_s][:opened].group_by { |e| Date.parse(e).monday }
  closed = summary[s["service_code"].to_s][:closed].group_by { |e| Date.parse(e).monday }

  next if opened.empty? || closed.empty?

  start  = opened.keys.min
  finish = [opened.keys.max, closed.keys.max].max


  week = start

  history = []

  while week <= finish
    history << [week, { :open  => (opened[week] || []).count, 
                        :close => (closed[week] || []).count }]
    week += 7
  end

  history.each_cons(2) do |(_,a), (_,b)|
    b[:open]  += a[:open]
    b[:close] += a[:close]
  end

  File.open("data/#{s["service_name"].parameterize}.csv", "w") do |f|
    history.each do |week, stats|
      f.puts [week.strftime("%Y%m%d"), stats[:open], stats[:close]].to_csv
    end
  end
end