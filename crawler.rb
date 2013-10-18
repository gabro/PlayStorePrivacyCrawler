require 'mechanize'
require 'treat'
include Treat::Core::DSL
require 'benchmark'
require 'colorize'
require 'timeout'


# Courtesy from http://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby
# Cross-platform way of finding an executable in the $PATH.
#
#   which('ruby') #=> /usr/bin/ruby
def which(cmd)
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    exts.each { |ext|
      exe = File.join(path, "#{cmd}#{ext}")
      return exe if File.executable? exe
    }
  end
  return nil
end

checkmark = "\u2713".green
xmark = "\u2718".red
circle = "\u25CB".white

time = Benchmark.realtime do
	## Validate arguments
	unless ARGV.length == 1
	  puts "Wrong number of arguments. Expected 1, given #{ARGV.length}"
	  abort
	end

	## Build Play Store URL
	package_name = ARGV.first.chomp
	play_store_url = "https://play.google.com/store/apps/details?id=#{package_name}"
	
	## Search for "Privacy Policy" link in Play Store
	privacy_url = nil
	time = Benchmark.realtime do
		browser = Mechanize.new
		browser.follow_meta_refresh = true
		browser.get(play_store_url) do |page|
			privacy_link = page.link_with(:text => / Privacy Policy /)
			unless privacy_link.nil?
				begin
					privacy_page = browser.click(privacy_link)
					privacy_url = privacy_page.uri.to_s
				rescue Mechanize::ResponseCodeError => e
					puts "#{checkmark} Searched Play Store for privacy policy #{time}"
					puts "    #{xmark} Found URL #{e.page.uri.to_s.underline.light_red} but it appears to be invalid"
					abort
				end
			end
		end
	end
	time = "(#{time} s)".cyan
	puts "#{checkmark} Searched Play Store for privacy policy #{time}"

	if privacy_url.nil?
		puts "    #{xmark} No privacy policy found for #{package_name.yellow}"
		abort
	end
	puts "    #{checkmark} Found privacy policy for #{package_name.yellow} at #{privacy_url.underline.light_red}"

	## Download privacy policy document
	privacy_doc = nil
	time = Benchmark.realtime do
		begin
			Timeout.timeout(10) do
				privacy_doc = document privacy_url
			end
		rescue Timeout::Error, Treat::Exception
			puts "#{xmark} A timeout error occurred while downloading the privacy policy from #{privacy_url.underline.light_red}"
			abort
		end
	end
	time = "(#{time} s)".cyan
	puts "#{checkmark} Downloaded privacy policy #{time}"

	## Parse privacy policy document
	time = Benchmark.realtime do
		privacy_doc.apply :chunk, :segment, :tokenize
	end
	time = "(#{time} s)".cyan
	puts "#{checkmark} Parsed privacy policy #{time}"

	## Export .dot file
	time = Benchmark.realtime do
		privacy_doc.visualize :dot, file: "#{package_name}.dot"
	end
	time = "(#{time} s)".cyan
	puts "#{checkmark} Generated .dot file #{time}"

	if which('dot').nil?
		dot = "dot".yellow
		puts "#{circle} Skipping .pdf generation as #{dot} is not installed"
	else
		## Export .pdf file
		time = Benchmark.realtime do
			`dot -o #{package_name}.pdf -Tpdf #{package_name}.dot`
		end
		time = "(#{time} s)".cyan
		puts "#{checkmark} Generated .pdf file #{time}"

		## Open .pdf file
		`open #{package_name}.pdf`
	end
end

## Final stats
puts "-----------------------------------------"
time = "#{time} s".cyan
puts "#{checkmark} Done! Total elapsed time: #{time}"