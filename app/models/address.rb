class Address < ActiveRecord::Base
  belongs_to :member

  before_save :update_number

  def calculated_addressee
    if addressee.blank?
      return member.name_with_title
    else
      return addressee
    end
  end

  def calculated_greeting
    if greeting.blank?
      return member.first_name
    else
      return greeting
    end
  end

  def self.duplicated_address_csv
    CSV.generate do |csv|
      csv << (["address", "zip", "member"])
      duplicated_addresses.each do |duplicate|
        Address.where(number: duplicate.number, zip: duplicate.zip).find_each do |address|
          csv << [address.address1, address.zip, Member.get_name_by_id(address.member_id)]
        end
      end
    end
  end

  def self.duplicated_addresses
    where.not(address1: [nil, ""]).select([:number, :zip]).group([:number, :zip]).having("count(*) > 1")
  end

  private
  def update_number
    self.number = address1[/\d+/].to_i
  end

end
