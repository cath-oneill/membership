class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :first_name
      t.string :last_name
      t.string :address
      t.string :city
      t.string :state
      t.string :zip
      t.string :email
      t.string :email2
      t.string :cell_phone
      t.string :home_phone
      t.string :work_phone
      t.string :employer
      t.string :occupation
      t.string :title

      t.timestamps
    end
  end
end
