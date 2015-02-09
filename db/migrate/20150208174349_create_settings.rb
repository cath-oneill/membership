class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.text :lookup
      t.text :value
    end
  end
end
