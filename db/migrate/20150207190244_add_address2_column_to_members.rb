class AddAddress2ColumnToMembers < ActiveRecord::Migration
  def change
    add_column :members, :address2, :string
  end
end
