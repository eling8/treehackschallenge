class CreatePeople < ActiveRecord::Migration
  def up
  	create_table :people do |t|
  		t.string :name
  		t.string :number
  		t.timestamps null: false
  	end
  end
 
  def down
  	drop_table :people
  end
end
