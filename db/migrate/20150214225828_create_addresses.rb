class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :address
      t.string :address2
      t.string :city
      t.string :state
      t.string :zip
      t.boolean :skip_mail
      t.string :addressee
      t.string :greeting
      t.boolean :primary
      t.references :member, index: true

      t.timestamps
    end
  end
end
