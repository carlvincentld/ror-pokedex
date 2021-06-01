class PokedexEntry < ApplicationRecord
  POKEMON_TYPES = [
    'Bug',
    'Dark',
    'Dragon',
    'Electric',
    'Fairy',
    'Fighting',
    'Fire',
    'Flying',
    'Ghost',
    'Grass',
    'Ground',
    'Ice',
    'Normal',
    'Poison',
    'Psychic',
    'Rock',
    'Steel',
    'Water'
  ]

  validates :no, numericality: { only_integer: true, greater_than: 0 }
  validates :name, presence: true, uniqueness: { scope: :no }
  validates :type1, presence: true , inclusion: { in: POKEMON_TYPES }
  validates :type2, inclusion: { in: POKEMON_TYPES }, allow_blank: true

  attribute :total

  validates :hp, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :attack, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :defense, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :spAtk, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :spDef, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :speed, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :generation, numericality: { only_integer: true, greater_than: 0 }
  validates :legendary, inclusion: { in: [true, false] }

  def total
    hp + attack + defense + spAtk + spDef + speed
  end

  def as_json(options)
    options ||= {}
    (options.methods ||= []).push(:total)
    super(options)
  end
end
