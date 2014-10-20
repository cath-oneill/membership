json.array!(@members) do |member|
  json.extract! member, :id, :first_name, :last_name, :address, :city, :state, :zip, :email, :cell_phone, :home_phone, :work_phone, :employer, :occupation, :title
  json.url member_url(member, format: :json)
end
