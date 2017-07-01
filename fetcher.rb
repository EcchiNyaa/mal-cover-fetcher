require 'myanimelist'       # MyAnimeList API.
require 'nokogiri'          # HTTP.
require 'open-uri'          # HTTP.

DIR = File.dirname(__FILE__)
CONFIG = YAML.load_file("#{DIR}/config.yml")

abort "Config file not found." unless File.exists? "#{DIR}/config.yml"

MyAnimeList.configure do |config|
    config.username = CONFIG['myanimelist_user']
    config.password = CONFIG['myanimelist_pass']
end

module Busca
  def search( titulo, titulo_original = nil )
    search = MyAnimeList.search_anime( titulo )

    if search.kind_of?(Array)
      # Se for um array, significa que mais de um resultado foi encontrado.

      distancia = Array.new
      resultado = Array.new

      # Se o <titulo_original> não for "nil", significa que nada foi encontrado utilizando
      # o <titulo>, então foi pequisado outra vez com outro <titulo>.
      search.each do |result|
        resultado.push "#{result['title']} , #{result['image']}"
        distancia.push levenshtein_distance titulo, result['title'] if titulo_original == nil
        distancia.push levenshtein_distance titulo_original, result['title'] unless titulo_original == nil
      end

      # Faz um catalogo de proximidade entre strings, e escolhe o menor.
      res = resultado.zip distancia
      res = res.min_by(&:last)

      # res[0] = "Titulo do MAL , URL da imagem"
      return res[0]
    else
      # Apenas um resultado foi encontrado.
      # retorna "Titulo do MAL , URL da imagem"
      return "#{search['title']} , #{search['image']}"
    end
  end
end

# Refinamento utilizando distância Levenshtein.
# https://stackoverflow.com/questions/16323571/measure-the-distance-between-two-strings-with-ruby
module Refinamento
  def levenshtein_distance(s, t)
    m = s.length
    n = t.length
    return m if n == 0
    return n if m == 0
    d = Array.new(m+1) {Array.new(n+1)}

    (0..m).each {|i| d[i][0] = i}
    (0..n).each {|j| d[0][j] = j}
    (1..n).each do |j|
      (1..m).each do |i|
        d[i][j] = if s[i-1] == t[j-1]
                    d[i-1][j-1]
                  else
                    [ d[i-1][j]+1,
                      d[i][j-1]+1,
                      d[i-1][j-1]+1,
                    ].min
                  end
      end
    end
    d[m][n]
  end
end

include Refinamento
include Busca

content = Nokogiri::HTML( open( "http://ecchinyaa.org/animes", "User-Agent" => "EcchiNyaa Bot->Github" ) )
links = content.css ".entry-content a"

count = 0
links.each do |link|
  count += 1
  begin
    res = search link.text
    # "1 , ORIGINAL , MAL , LINK IMAGEM"
    puts "#{count} , #{link.text} , #{res}"
  rescue MyAnimeList::ApiException
    begin
      # Tenta outra vez, mas utilizando apenas a primeira palavra.
      res = search link.text.partition( " " ).first, link.text
      puts "#{count} , #{link.text} , #{res}"
    rescue MyAnimeList::ApiException
      puts "#{count} , ERRO!"
    end
  end
end
