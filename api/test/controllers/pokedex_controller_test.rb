require "test_helper"
require "json"
require "set"

# INFO: RAILS_ENV=test bin/rails db:seed doit avoir été roulé pour faire fonctionner ces tests
class PokedexControllerTest < ActionDispatch::IntegrationTest
  # INDEX
  test "get index should return JSON" do
    get pokedex_index_path()
    pokedex = JSON.parse(@response.body)

    assert_response :success
  end

  # SHOW
  test "show should return item with id" do
    get pokedex_path(1)
    assert_response :success

    entry = JSON.parse(@response.body)
    assert_equal entry["no"], 1
    assert_equal entry["name"], "Bulbasaur"
    assert_equal entry["total"], 318
  end

  [ 'color', -1 ].each do |id|
    test "show with invalid id (#{id}) should throw bad_request" do
      get pokedex_path(id)
      assert_response :bad_request
    end
  end

  # CREATE
  test "create with missing params should return bad_request" do
    post pokedex_index_path(), params: {}
    assert_response :bad_request

    response = JSON.parse(@response.body)
    assert_not_empty response["error"]
    assert_not_empty response["errors"]
  end

  test "create with a single type should return new entry" do
    name = "BulbasaurVariant"
    type1 = "Grass"
    type2 = nil
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
    assert_response :success

    entry = JSON.parse(@response.body)
    assert_equal entry["name"], name
    assert_equal entry["type1"], type1
    assert_nil entry["type2"]
  end

  test "create with a two types should return new entry" do
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
    assert_response :success

    entry = JSON.parse(@response.body)
    assert_equal entry["name"], name
    assert_equal entry["type1"], type1
    assert_equal entry["type2"], type2
  end

  # UPDATE
  test "update with invalid parameters should return bad_request" do
    get pokedex_path(1)
    assert_response :success
    entry = JSON.parse(@response.body)
    entry["name"] = nil
    entry["no"] = nil

    put pokedex_path(1), params: entry
    assert_response :bad_request

    response = JSON.parse(@response.body)
    assert_not_empty response["error"]
    assert_not_empty response["errors"]
  end

  [ 'color', -1, 1000000 ].each do |id|
    test "update with invalid or missing id (#{id}) should throw bad_request" do
      put pokedex_path(id), params: {}
      assert_response :bad_request

      response = JSON.parse(@response.body)
      assert_not_empty response["error"]
      assert_nil response["errors"]
    end
  end

  test "update should only change given parameters" do
    get pokedex_path(1)
    assert_response :success
    entry = JSON.parse(@response.body, object_class: PokedexEntry)

    put pokedex_path(1), params: { name: "Bulbizarre" }
    assert_response :success
    modifiedEntry = JSON.parse(@response.body, object_class: PokedexEntry)

    modifiedAttributes = (entry.attributes.to_a - modifiedEntry.attributes.to_a).map(&:first)
    assert_equal modifiedEntry.name, "Bulbizarre"
    assert_equal modifiedAttributes, ["name", "updated_at"]
  end

  # DELETE
  [ 'color', -1, 1000000 ].each do |id|
    test "destroy with invalid or missing id (#{id}) should throw bad_request" do
      delete pokedex_path(id), params: {}
      assert_response :bad_request

      response = JSON.parse(@response.body)
      assert_not_empty response["error"]
      assert_nil response["errors"]
    end
  end

  test "destroy with existint entry should return deleting entry" do
    get pokedex_path(1)
    assert_response :success
    entry = JSON.parse(@response.body, object_class: PokedexEntry)

    delete pokedex_path(1)
    assert_response :success
    deletedEntry = JSON.parse(@response.body, object_class: PokedexEntry)

    modifiedAttributes = (entry.attributes.to_a - deletedEntry.attributes.to_a).map(&:first)
    assert_empty modifiedAttributes
  end

  # PAGINATION
  test "get pagination should return 100 items" do
    get pokedex_pagination_path()
    assert_response :success

    pokedex = JSON.parse(@response.body)
    assert_equal pokedex["meta"]["limit"], 100
    assert_equal pokedex["meta"]["offset"], 0
    assert_equal pokedex["entries"].count, 100
  end

  # CAVEAT: It's unlikely there'll be 1 000 000 pokedex entries
  [ 50, 1000000 ].each do |limit|
    test "get pagination with limit of #{limit} should return #{limit} items or less" do
      get pokedex_pagination_path(), params: { limit: limit }
      assert_response :success

      pokedex = JSON.parse(@response.body)
      assert_equal pokedex["meta"]["limit"], limit
      assert_equal pokedex["meta"]["offset"], 0
      assert_operator pokedex["entries"].count, :<=, limit
    end
  end

  test "get pagination's next page should return distinct items" do
    limit = 10
    offset = 0

    get pokedex_pagination_path(), params: { offset: offset, limit: limit }
    assert_response :success

    page0 = JSON.parse(@response.body)
    entries0 = page0["entries"].map { |entry| entry["id"] }

    get pokedex_pagination_path(), params: { offset: offset + limit, limit: limit }
    assert_response :success

    page1 = JSON.parse(@response.body)
    entries1 = page1["entries"].map { |entry| entry["id"] }

    assert_equal entries0 & entries1, []
  end

  [ 'color', 0, 1.5 ].each do |limit|
    test "get pagination with invalid (#{limit}) limit should throw" do
      get pokedex_pagination_path(), params: { limit: limit }
      assert_response :bad_request
    end
  end

  [ 'color', -1, 1.5 ].each do |offset|
    test "get pagination with invalid (#{offset}) offset should throw" do
      get pokedex_pagination_path(), params: { offset: offset }
      assert_response :bad_request
    end
  end
end
