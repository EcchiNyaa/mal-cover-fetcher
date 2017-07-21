require "sqlite3"
require "sequel"

module Database
  DB = Sequel.connect("sqlite://#{DIR}/database/cover.db")

  Sequel.extension :migration
  Sequel::Migrator.run DB, "#{DIR}/database/migrations"

  class Result < Sequel::Model
    def show
      puts "#{name} ( #{mal_name} ) :: #{cover_url}"
    end
  end
end
