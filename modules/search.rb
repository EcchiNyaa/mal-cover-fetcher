require "open-uri"
require "xmlsimple"

module Parser
  def search title
    range = [title, title.partition( " " ).first, title.partition( " " ).last]

    for try in range
      page = self.api try
      break success = true if page.status.first == "200"
    end

    return nil unless success

    response = Array.new
    content = XmlSimple.xml_in page

    content["entry"].each do |anime|
      response << {
        distance: levenshtein_distance(title, anime["title"].first),
        name: title,
        mal_name: anime["title"].first,
        cover: anime["image"].first
      }
    end

    response.min_by { |res| res[:distance] }
  end
end
