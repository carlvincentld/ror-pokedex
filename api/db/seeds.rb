# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require "csv"

pokedex_path = File.join(Rails.root, "db", "data", "pokedex.csv")
PokedexEntry.transaction do
  CSV.foreach(pokedex_path , skip_blanks: true, headers: true) do |row|
    entry = PokedexEntry.new(
      no: Integer(row["#"]),
      name: row["Name"],
      type1: row["Type 1"],
      type2: row["Type 2"],
      hp: Integer(row["HP"]),
      attack: Integer(row["Attack"]),
      defense: Integer(row["Defense"]),
      spAtk: Integer(row["Sp. Atk"]),
      spDef: Integer(row["Sp. Def"]),
      speed: Integer(row["Speed"]),
      generation: Integer(row["Generation"]),
      legendary: 
        case row["Legendary"].downcase
          when "true" then true
          when "false" then false
          else nil
        end
    )
    entry.save!
  end
end
