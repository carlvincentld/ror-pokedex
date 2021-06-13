require 'rails_helper'

RSpec.describe PokedexEntry, type: :model do
  let!(:bulbasaur) {
    described_class.new(
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
  }

  it "with complete entry should be valid" do
    expect(bulbasaur).to be_valid
  end

  describe "entry number" do
    it "without entry number should be invalid" do
      bulbasaur.no = nil
      expect(bulbasaur).to_not be_valid
    end

    it "with decimal entry number should be invalid" do
      bulbasaur.no = Float(0.5)
      expect(bulbasaur).to_not be_valid
    end

    it "with nought entry number should be invalid" do
      bulbasaur.no = 0
      expect(bulbasaur).to_not be_valid
    end
  end

  describe "name" do
    it "without name should be invalid" do
      bulbasaur.name = nil
      expect(bulbasaur).to_not be_valid
    end

    it "with duplicate (entry number, name) pair should be invalid" do
      expect(bulbasaur.save).to be(true)
      clone = bulbasaur.dup
      expect(clone).to_not be_valid
    end

    it "with unique (entry number, name) pair should be valid" do
      expect(bulbasaur.save).to be(true)

      numClone = bulbasaur.dup
      numClone.name = "BulbasaureMega Bulbasaur"
      expect(numClone).to be_valid

      nameClone = bulbasaur.dup
      nameClone.no = 2
      expect(nameClone).to be_valid
    end
  end

  describe "types" do
    it "without first type should be invalid" do
      bulbasaur.type1 = nil
      expect(bulbasaur).to_not be_valid
    end

    [:type1, :type2].each do |type|
      it "with an erroneous type #{type} should be invalid" do
        bulbasaur[type] = "erroneous type"
        expect(bulbasaur).to_not be_valid
      end
    end

    it "without second type should be valid" do
      bulbasaur.type2 = nil
      expect(bulbasaur).to be_valid
    end

    it "with type1 = type2 should be invalid" do
      bulbasaur.type2 = bulbasaur.type1 = "Grass"
      expect(bulbasaur).to_not be_valid
    end
  end

  describe "stats" do
    [:hp, :attack, :defense, :spAtk, :spDef, :speed].each do |stat|
      it "without #{stat} type should be invalid" do
        bulbasaur[stat] = nil
        expect(bulbasaur).to_not be_valid
      end

      it "with decimal #{stat} should be invalid" do
        bulbasaur[stat] = Float(0.5)
        expect(bulbasaur).to_not be_valid
      end

      it "with negative #{stat} should be invalid" do
        bulbasaur[stat] = -1
        expect(bulbasaur).to_not be_valid
      end
    end
  end

  describe "generation" do
    it "without generation should be invalid" do
      bulbasaur.generation = nil
      expect(bulbasaur).to_not be_valid
    end

    it "with decimal generation should be invalid" do
      bulbasaur.generation = Float(0.5)
      expect(bulbasaur).to_not be_valid
    end

    it "with negative generation should be invalid" do
      bulbasaur.generation = -1
      expect(bulbasaur).to_not be_valid
    end
  end

  describe "legendary" do
    it "without legendary flag should be invalid" do
      bulbasaur.legendary = nil
      expect(bulbasaur).to_not be_valid
    end
  end

  describe "total" do
    it "total should be the sump of all stats" do
      expect(bulbasaur.total).to be(1 + 2 + 3 + 4 + 5 + 6)
    end
  end
end
