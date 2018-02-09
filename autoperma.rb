##
##  This script takes a CSV that contains URLs and titles and generates Perma archives for each URL, then creates a new CSV spreadsheet containing the URLs of each Perma archive
##

require 'csv'
require 'net/http'
require 'uri'
require 'json'

write_rows = Array.new
first_row = true
CSV.foreach('INPUT.csv') do |row| # Specify the name of the input csv spreadsheet here
	if first_row # This code assumes that the first row of the spreadsheet contains column headers, and so it should not generate a Perma archive for that row
		first_row = false
		next
	end

	uri = URI.parse("https://api.perma.cc/v1/archives/?api_key=PERMA_API_KEY_GOES_HERE") # Update this to use your Perma API key
	request = Net::HTTP::Post.new(uri)
	request.content_type = "application/json"
	request.body = JSON.dump({ 
	  "url" => row[4], # Set the input URL from the correct column in the csv spreadsheet
	  "title" => row[5], # Set the title from the correct column in the csv spreadsheet
	  "folder" => 00000 # This number should be updated to whatever the Perma folder number is  - this can be found by inspecting the element of the folder icon in the Perma web browser
	})

	req_options = {
	  use_ssl: uri.scheme == "https",
	}

	response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
	  http.request(request)
	end

	# Parse the response
	perma_url = JSON.parse(response.body)["guid"]
	row.push("https://perma.cc/" + perma_url)
	write_rows.push(row)
	
puts "Archived " + row[5] + " to: " + "https://perma.cc/" + perma_url
end

CSV.open('OUTPUT.csv', 'wb') do |csv| # OUTPUT can be renamed to whatevet you want the output csv to be called
	write_rows.each do |wr|
		csv << wr
	end
end
