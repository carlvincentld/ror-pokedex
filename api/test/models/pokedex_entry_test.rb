require "test_helper"

# TODO: Trouver un meilleur moyen de tester les règles de validation pour découpler les messages de rails
class PokedexEntryTest < ActiveSupport::TestCase
  test "missing entry no should be invalid" do
    entry = PokedexEntry.new
    assert entry.invalid?
    assert_includes entry.errors[:no], "is not a number"
  end

  test "floating point entry no should be invalid" do
    entry = PokedexEntry.new(no: Float(1.5))
    assert entry.invalid?
    assert_includes entry.errors[:no], "must be an integer"
  end

  test "0th entry no should be invalid" do
    entry = PokedexEntry.new(no: Integer(0))
    assert entry.invalid?
    assert_includes entry.errors[:no], "must be greater than 0"
  end

  test "missing name should be invalid" do
    entry = PokedexEntry.new
    assert entry.invalid?
    assert_includes entry.errors[:name], "can't be blank"
  end

  test "missing first type should be invalid" do
    entry = PokedexEntry.new
    assert entry.invalid?
    assert_includes entry.errors[:type1], "is not included in the list"
  end

  [:type1, :type2].each do |type|
    test "wrong type for #{type} should be invalid" do
      entry = PokedexEntry.new
      entry[type] = "missing"
      assert entry.invalid?
      assert_includes entry.errors[type], "is not included in the list"
    end
  end

  [:hp, :attack, :defense, :spAtk, :spDef, :speed].each do |stat|
    test "missing #{stat} should be invalid" do
      entry = PokedexEntry.new
      assert entry.invalid?
      assert_includes entry.errors[stat], "is not a number"
    end

    test "floating point #{stat} should be invalid" do
      entry = PokedexEntry.new
      entry[stat] = Float(0.5)
      assert entry.invalid?
      assert_includes entry.errors[stat], "must be an integer"
    end

    test "negative #{stat} should be invalid" do
      entry = PokedexEntry.new
      entry[stat] = -1
      assert entry.invalid?
      assert_includes entry.errors[stat], "must be greater than or equal to 0"
    end
  end 

  test "missing generation should be invalid" do
    entry = PokedexEntry.new
    assert entry.invalid?
    assert_includes entry.errors[:generation], "is not a number"
  end

  test "0th generation should be invalid" do
    entry = PokedexEntry.new(generation: Integer(0))
    assert entry.invalid?
    assert_includes entry.errors[:generation], "must be greater than 0"
  end

  test "missing legendary should be invalid" do
    entry = PokedexEntry.new
    assert entry.invalid?
    assert_includes entry.errors[:legendary], "is not included in the list"
  end

  test "1 typed entry should be valid" do
    entry = PokedexEntry.new(
      no: 4,
      name: "Charmander",
      type1: "Fire",
      hp: 39,
      attack: 52,
      defense: 43,
      spAtk: 60,
      spDef: 50,
      speed: 65,
      generation: 1,
      legendary: false
    )
    assert entry.valid?
  end

  test "1 typed entry with blank type2 should be valid" do
    entry = PokedexEntry.new(
      no: 4,
      name: "Charmander",
      type1: "Fire",
      type2: "",
      hp: 39,
      attack: 52,
      defense: 43,
      spAtk: 60,
      spDef: 50,
      speed: 65,
      generation: 1,
      legendary: false
    )
    assert entry.valid?
  end

  test "2 typed entry should be valid" do
    entry = PokedexEntry.new(
      no: 1,
      name: "Bulbasaur",
      type1: "Grass",
      type2: "Poison",
      hp: 45,
      attack: 49,
      defense: 49,
      spAtk: 65,
      spDef: 65,
      speed: 45,
      generation: 1,
      legendary: false
    )
    assert entry.valid?
  end

  test "duplicate no-name entry should be invalid" do
    bulbasaur1 = PokedexEntry.new(
      no: 1,
      name: "Bulbasaur",
      type1: "Grass",
      type2: "Poison",
      hp: 1,
      attack: 1,
      defense: 1,
      spAtk: 1,
      spDef: 1,
      speed: 1,
      generation: 1,
      legendary: false
    )
    assert bulbasaur1.save

    bulbasaur2 = PokedexEntry.new(
      no: 1,
      name: "Bulbasaur",
      type1: "Grass",
      type2: "Poison",
      hp: 2,
      attack: 2,
      defense: 2,
      spAtk: 2,
      spDef: 2,
      speed: 2,
      generation: 2,
      legendary: false
    )
    assert bulbasaur2.invalid?
    assert_includes bulbasaur2.errors[:name], "has already been taken"
  end

  test "mega-evolution entry should be valid" do
    venusaur = PokedexEntry.new(
      no: 3,
      name: "Venusaur",
      type1: "Grass",
      type2: "Poison",
      hp: 80,
      attack: 82,
      defense: 83,
      spAtk: 100,
      spDef: 100,
      speed: 80,
      generation: 1,
      legendary: false
    )
    assert venusaur.save

    megaVenusaur = PokedexEntry.new(
      no: 3,
      name: "VenusaurMega Venusaur",
      type1: "Grass",
      type2: "Poison",
      hp: 80,
      attack: 100,
      defense: 123,
      spAtk: 122,
      spDef: 120,
      speed: 80,
      generation: 1,
      legendary: false
    )
    assert megaVenusaur.valid?
  end

  test "total should be the sum of hp, attack, defense, special attack, special defense and speed" do
    entry = PokedexEntry.new(
      no: 1,
      name: "Bulbasaur",
      type1: "Grass",
      type2: "Poison",
      hp: 1,
      attack: 2,
      defense: 3,
      spAtk: 4,
      spDef: 5,
      speed: 6,
      generation: 1,
      legendary: false
    )
    assert_equal entry.total, 1 + 2 + 3 + 4 + 5 + 6
  end
end
