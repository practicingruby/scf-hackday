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

opened = summary["116"][:opened].group_by { |e| Date.parse(e).monday }
closed = summary["116"][:closed].group_by { |e| Date.parse(e).monday }

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

history.each do |week, stats|
  puts [week.strftime("%Y%m%d"), stats[:open], stats[:close]].to_csv
end



=begin

require "active_support"
require 'active_support/core_ext'

sd = JSON.parse(File.read("services.json"))
services = {}

sd.each do |e|
  services[e["service_code"]] = e["service_name"].parameterize
end

rows = []

CSV.foreach("dump-2000.csv", :headers => true) do |row|
  rows << [Date.parse(row['created_at'] || Date.today.to_s), (Date.parse(row["created_at"] || Date.today.to_s) + rand(180)), row['request_type_id'].to_i]
end

grouped_data = rows.sort_by { |e| e[0] }.map { |e| [e[0], e[1], services[e[2]]] }.group_by { |e| e[2] }


summary = Hash.new { |h,k|
            h[k] = Hash.new { |h,k| h[k] = { :opened => 0, :closed => 0} }
          }


# FIXME: Work with *every* week, not just weeks from issue data



grouped_data.each do |service, rows|
  rows.each do |e|
    # FIXME: strip out nil values for opened / closed
    summary[service][e[0].monday][:opened] += 1
    summary[service][e[1].monday][:closed] += 1
  end
end

p summary["graffiti"].keys.min
p summary["graffiti"].keys.

=end