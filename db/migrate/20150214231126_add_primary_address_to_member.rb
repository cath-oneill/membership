class AddPrimaryAddressToMember < ActiveRecord::Migration
  def change
    add_reference :members, :primary_address, index: true
  end
end
