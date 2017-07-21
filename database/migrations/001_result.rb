Sequel.migration do
  up do
    create_table :results do
      primary_key :id

      String :name
      String :mal_name
      String :cover_url
    end
  end

  down do
    drop_table(:results)
  end
end
