class Address < ActiveRecord::Base
  belongs_to :member

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

end
