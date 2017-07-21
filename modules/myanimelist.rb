require "open-uri"
require "addressable/uri"

module MyAnimeList
  def api name
    user = CONFIG["myanimelist_user"]
    pass = CONFIG["myanimelist_pass"]

    url = "https://myanimelist.net/api/anime/search.xml?q=#{name}"
    buffer = Addressable::URI.parse(url).normalize.to_s

    open(buffer, http_basic_authentication: [user, pass])
  end
end
