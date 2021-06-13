require 'rails_helper'

RSpec.describe PokedexController, type: :request do
  around(:each) do |ex|
    create_entry(1, "Bulbasaur")
    create_entry(2, "Ivysaur")
    create_entry(3, "Venusaur")
    create_entry(4, "Charmander")
    create_entry(5, "Charmeleon")
    create_entry(6, "Charizard")
    create_entry(7, "Squirtle")
    create_entry(8, "Watortle")
    create_entry(9, "Blastoise")
    ex.run
  end

  describe "GET" do
    it "get index should fetch the whole pokedex" do
      get pokedex_index_path

      expect(response).to have_http_status(200)
      expect(response.content_type).to include("application/json")

      content = JSON.parse(response.body)
      expect(content.length).to be(9)
    end
  end

  describe "SHOW" do
    [ 'color', -1 ].each do |id|
      it "SHOW invalid id (#{id}) should generate bad request" do
        get pokedex_path(id: id)
        expect(response).to have_http_status(400)
      end
    end

    it "SHOW first entry of GET should return same entry" do
      get pokedex_index_path

      expect(response).to have_http_status(200)
      expect(response.content_type).to include("application/json")
      content = JSON.parse(response.body)

      first = content[0]

      get pokedex_path(id: first["id"])
      expect(response).to have_http_status(200)
      expect(response.content_type).to include("application/json")

      fetched = JSON.parse(response.body)

      expect(fetched).to eq(first)
    end
  end

  describe "CREATE" do
    it "CREATE with missing parameters shoud return bad request" do
      post pokedex_index_path(), params: {}
      expect(response).to have_http_status(400)
    end

    it "CREATE variant should create new entry" do
      name = "BulbasaurVariant"
      type1 = "Grass"
      variant = {
        no: 1,
        name: name,
        type1: type1,
        hp: 1,
        attack: 1,
        defense: 1,
        spAtk: 1,
        spDef: 1,
        speed: 1,
        generation: 1,
        legendary: false
      }

      post pokedex_index_path(), params: variant
      expect(response).to have_http_status(200)
      expect(response.content_type).to include("application/json")

      bulbasaurVariant = JSON.parse(response.body)
      expect(bulbasaurVariant["name"]).to eq(name)
      expect(bulbasaurVariant["type1"]).to eq(type1)
      expect(bulbasaurVariant["type2"]).to eq(nil)

      get pokedex_index_path
      expect(response).to have_http_status(200)
      expect(response.content_type).to include("application/json")

      pokedex = JSON.parse(response.body)
      expect(pokedex).to include(bulbasaurVariant)
    end

    it "CREATE variant with 2 types should create new entry" do
      name = "BulbasaurVariant"
      type1 = "Grass"
      type2 = "Poison"
      variant = {
        no: 1,
        name: name,
        type1: type1,
        type2: type2,
        hp: 1,
        attack: 1,
        defense: 1,
        spAtk: 1,
        spDef: 1,
        speed: 1,
        generation: 1,
        legendary: false
      }

      post pokedex_index_path(), params: variant
      expect(response).to have_http_status(200)
      expect(response.content_type).to include("application/json")

      bulbasaurVariant = JSON.parse(response.body)
      expect(bulbasaurVariant["name"]).to eq(name)
      expect(bulbasaurVariant["type1"]).to eq(type1)
      expect(bulbasaurVariant["type2"]).to eq(type2)

      get pokedex_index_path
      expect(response).to have_http_status(200)
      expect(response.content_type).to include("application/json")

      pokedex = JSON.parse(response.body)
      expect(pokedex).to include(bulbasaurVariant)
    end
  end

  describe "UPDATE" do
    [ 'color', -1 ].each do |id|
      it "UPDATE with invalid id (#{id}) should yield bad request" do
        get pokedex_path(id: id)
        expect(response).to have_http_status(400)
      end
    end

    it "UPDATE existing entry should only change given parameters" do
      get pokedex_index_path

      expect(response).to have_http_status(200)
      expect(response.content_type).to include("application/json")
      content = JSON.parse(response.body)

      first = content[0]
      put pokedex_path(id: first["id"]), params: { name: nil }
      expect(response).to have_http_status(400)
    end

    it "UPDATE existing entry should only change given parameters" do
      get pokedex_index_path

      expect(response).to have_http_status(200)
      expect(response.content_type).to include("application/json")
      content = JSON.parse(response.body)

      first = content[0]
      put pokedex_path(id: first["id"]), params: { name: "Bulbizarre" }
      expect(response).to have_http_status(200)
      expect(response.content_type).to include("application/json")

      fetched = JSON.parse(response.body)
      expect(fetched["name"]).to eq("Bulbizarre")
    end
  end

  describe "DELETE" do
    [ 'color', -1 ].each do |id|
      it "DELETE with invalid id (#{id}) should yield bad request" do
        delete pokedex_path(id: id)
        expect(response).to have_http_status(400)
      end
    end

    it "DELETE entry once should delete entry" do
      get pokedex_index_path

      expect(response).to have_http_status(200)
      expect(response.content_type).to include("application/json")
      content = JSON.parse(response.body)

      first = content[0]
      delete pokedex_path(id: first["id"])
      expect(response).to have_http_status(200)
      expect(response.content_type).to include("application/json")

      get pokedex_index_path

      expect(response).to have_http_status(200)
      expect(response.content_type).to include("application/json")
      content = JSON.parse(response.body)

      expect(content).to_not include first
    end

    it "DELETE entry two should should fail" do
      get pokedex_index_path

      expect(response).to have_http_status(200)
      expect(response.content_type).to include("application/json")
      content = JSON.parse(response.body)

      first = content[0]
      delete pokedex_path(id: first["id"])
      expect(response).to have_http_status(200)
      expect(response.content_type).to include("application/json")

      delete pokedex_path(id: first["id"])
      expect(response).to have_http_status(400)
    end
  end

  describe "PAGINATION" do
    [ 'color', 0, 1.5 ].each do |limit|
      it "PAGINATION with invalid limit (#{limit}) should yield bad request" do
        get pokedex_pagination_path(), params: { limit: limit }
        expect(response).to have_http_status(400)
      end
    end

    [ 'color', -1, 1.5 ].each do |offset|
      it "PAGINATION with invalid offset (#{offset}) should yield bad request" do
        get pokedex_pagination_path(), params: { offset: offset }
        expect(response).to have_http_status(400)
      end
    end

    [ 5, 100 ].each do |limit|
      it "PAGINATION should return #{limit} items or less" do
        get pokedex_pagination_path(), params: { limit: limit }
        expect(response).to have_http_status(200)
        expect(response.content_type).to include("application/json")

        content = JSON.parse(response.body)
        expect(content.length).to be <= limit
      end
    end

    it "PAGINATION next pas should return distinct items" do
      limit = 5
      offset = 0
      get pokedex_pagination_path(), params: { limit: limit, offset: offset }
      expect(response).to have_http_status(200)
      expect(response.content_type).to include("application/json")

      firstPage = JSON.parse(response.body)
      firstIds = firstPage["entries"].map { |x| x["id"] }

      offset += limit
      get pokedex_pagination_path(), params: { limit: limit, offset: offset }
      expect(response).to have_http_status(200)
      expect(response.content_type).to include("application/json")

      secondPage = JSON.parse(response.body)
      secondIds = secondPage["entries"].map { |x| x["id"] }

      expect(secondIds & firstIds).to eq([])
    end
  end

  private

  def create_entry(no, name) 
    PokedexEntry.create!({
      no: no,
      name: name,
      type1: "Normal",
      hp: 1,
      attack: 2,
      defense: 3,
      spAtk: 4,
      spDef: 5,
      speed: 6,
      generation: 1,
      legendary: false
    })
  end
end
