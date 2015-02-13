class Setting < ActiveRecord::Base

  def self.value(lookup)
    Setting.find_by(lookup: lookup).value    
  end

  def self.list_values(lookup)
    Setting.find_by(lookup: lookup).value.scan(/\w+/)
  end

end