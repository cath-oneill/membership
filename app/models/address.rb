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
        next if duplicate[0].nil? || duplicate[1].nil?
        Address.where(number: duplicate[0], zip: duplicate[1]).find_each do |add|
          csv << [add.address1, add.zip, Member.get_name_by_id(add.member_id)]
        end
      end
    end
  end

  def self.duplicated_addresses
    select([:number, :zip]).group([:number, :zip]).having("count(*) > 1").map{|dup| [dup.number, dup.zip]}
  end

  private
  def update_number
    if address1.nil?
      self.number = nil
      return
    end
    self.number = address1[/\d+/].to_i
  end

end
