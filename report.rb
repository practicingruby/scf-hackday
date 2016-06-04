require "json"
require "csv"

issues = JSON.parse(File.read("potholes.json"))["issues"]

puts issues[0].keys.to_csv

issues.each { |e| puts e.values.to_csv }