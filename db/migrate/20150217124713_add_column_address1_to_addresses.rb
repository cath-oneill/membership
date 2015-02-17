class AddColumnAddress1ToAddresses < ActiveRecord::Migration
  def change
    remove_column :addresses, :address,  :string
    add_column    :addresses, :address1, :string
  end
end
