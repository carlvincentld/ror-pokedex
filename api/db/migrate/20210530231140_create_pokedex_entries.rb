class CreatePokedexEntries < ActiveRecord::Migration[6.1]
  def change
    create_table :pokedex_entries do |t|
      t.integer :no
      t.string :name
      t.string :type1
      t.string :type2
      t.integer :hp
      t.integer :attack
      t.integer :defense
      t.integer :spAtk
      t.integer :spDef
      t.integer :speed
      t.integer :generation
      t.boolean :legendary

      t.timestamps
    end

    add_index :pokedex_entries, [:no, :name], :unique => true
  end
end
