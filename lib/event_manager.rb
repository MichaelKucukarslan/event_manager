require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'date'

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

def save_form_letter(id, form_letter)
    Dir.mkdir('output') unless Dir.exist?('output')
    filename = "output/thanks_#{id}.html"
    File.open(filename, 'w') do |file|
        file.puts form_letter
    end
end

def clean_phone_number (phone_number)
    number = phone_number.delete("^0-9")
    if number.length == 10
        number
    elsif number.length == 11 && number[0] == "1"
        number[1..10]
    else
        "Invalid Number"
    end
end

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter
hour_registered = []
day_registered = []
contents.each do |row|
    id = row[0]
    name = row[:first_name]
    zipcode = clean_zipcode(row[:zipcode])
    # legislators = legislators_by_zipcode(zipcode)
    
    phone_number = clean_phone_number(row[:homephone])
    # puts phone_number
    date = DateTime.strptime(row[:regdate], '%m/%d/%y %H:%M')
    hour_registered.push(date.hour)
    day_registered.push(date.wday)
    # time = Time.parse(row[:regdate])
    # puts time unless id == 4
    # puts row[:regdate]
    # form_letter = erb_template.result(binding)
    # save_form_letter(id, form_letter) 
end
hour_registered = hour_registered.tally
hour_registered = hour_registered.sort {|a,b| -(a[1]<=>b[1])}
print hour_registered
puts ''
puts "Hour #{hour_registered[0][0]} had the most registrations with #{hour_registered[1][0]}, and #{hour_registered[2][0]} being the next most."
day_registered = day_registered.tally
day_registered = day_registered.sort {|a,b| -(a[1]<=>b[1])}
print day_registered
puts "Day #{day_registered[0][0]} had the most registrations with #{day_registered[1][0]}, and #{day_registered[2][0]} being the next most."
