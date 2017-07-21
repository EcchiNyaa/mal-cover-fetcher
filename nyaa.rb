require "yaml"
require "open-uri"
require "nokogiri"

DIR = File.dirname(__FILE__)
CONFIG = YAML.load_file "#{DIR}/config/config.yml"

# Require all modules.
Dir["#{DIR}/modules/*.rb"].each { |file| require file }

class Search
  include MyAnimeList
  include Levenshtein_Distance
  include Parser
end

q = Search.new

if ARGV.empty?
  url = "http://localhost/wordpress/animes"

  content = Nokogiri::HTML(open(url, "User-Agent" => "EcchiNyaa Cover Bot" ))
  animes = content.css ".entry-content a"

  animes.each do |anime|
    res = q.search anime.text
    log = Database::Result.create name: res[:name],
                                  mal_name: res[:mal_name],
                                  cover_url: res[:cover]

    log.show
  end
else
  res = q.search ARGV.join( " " )
  return if res.nil?
  puts "#{res[:name]} ( #{res[:mal_name]} ) :: #{res[:cover]}"
end
