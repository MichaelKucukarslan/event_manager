require 'csv'
require 'google/apis/civicinfo_v2'


puts 'Event Manager Initialized!'
# Use the CSV Library
contents = CSV.open(
    'event_attendees.csv',
    headers: true,
    header_converters: :symbol
)

def clean_zipcode(zipcode)
    zipcode.to_s.rjust(5, '0')[0..4]
end

def legislators_by_zipcode(zipcode)
    civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
    civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

    begin
        legislators = civic_info.representative_info_by_address(
            address: zipcode,
            levels: 'country',
            roles: ['legislatorUpperBody', 'legislatorLowerBody']
        )
        legislators = legislators.officials
        legislator_name = legislators.map(&:name)
        legislator_string = legislator_name.join(', ')
    rescue
        'You can find your representatives by visitying www.commoncause.org'
    end
end

contents.each do |row|
    name = row[:first_name]
    zipcode = clean_zipcode(row[:zipcode])
    legislators = legislators_by_zipcode(zipcode)
    
    puts "#{name} #{zipcode} #{legislators}"
end

# Read the file 
# lines = File.readlines('event_attendees.csv')
# lines.each_with_index do |line, index|
#     next if index == 0 # skips the first row
#     columns = line.split(",")
#     name = columns[2]
#     puts name
# end