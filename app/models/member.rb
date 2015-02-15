class Member < ActiveRecord::Base
  has_many :payments
  has_many :notes
  has_many :addresses
  has_one  :primary_address, :class_name => "Address"

  delegate :address, :address2, :city, :state, :zip, :skip_mail, to: :primary_address, allow_nil: true

  serialize :clubs, Array

  validates :first_name, :last_name, :presence => true
  validate  :all_clubs_are_valid

  filterrific(
    default_filter_params: { sorted_by: 'name_asc' },
    available_filters: [
      :search_query,
      :sorted_by,
      :by_zip_code,
      :last_dues_paid_gte,
      :selection
    ]
  )

  # default for will_paginate
  self.per_page = 10

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? :desc : :asc
    case sort_option.to_s
    when /^zip_/
      joins{primary_address.outer}.order("zip #{direction} NULLS LAST") 
    when /^dues_/
      order("dues_paid #{direction} NULLS LAST") 
    when /^name_/
      order(last_name: direction)
    else
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :search_query, lambda { |query|
    return nil  if query.blank?
    # condition query, parse into individual keywords
    q = query.split(" ").map{|x| "%#{x}%"}
    uniq.joins{notes.outer}.where{(first_name.like_any q) | (last_name.like_any q) | (notes.content.like_any q)}
  }

  scope :last_dues_paid_gte, lambda { |ref_date|
    where{dues_paid >= ref_date}
  }

  scope :by_zip_code, lambda { |zip|
    joins(:primary_address).where{primary_address.zip == zip.to_s}
  }

  scope :selection, lambda { |keyword|
    case keyword
    when "skipmail"
      uniq.joins(:addresses).where{(addresses.skip_mail == true)}
    when "greeting"
      uniq.joins(:addresses).where{(addresses.greeting != nil) & (addresses.greeting != "")}
    when "addressee"
      uniq.joins(:addresses).where{(addresses.addressee != nil) & (addresses.addressee != "")}  
    else
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }  

  def self.to_csv
    CSV.generate do |csv|
      csv << (column_names + ["calculated_mail_name", "calculated_greeting"])
      all.each do |member|
        information = member.attributes.values_at(*column_names)
        information << member.calculated_mail_name
        information << member.calculated_greeting
        csv << information
      end
    end
  end
    
  def self.duplicated_address_csv
    CSV.generate do |csv|
      csv << (["address"])
      all.each do |duplicate|
        csv << [duplicate.address]
      end
    end
  end

  def self.import_new(file)
    not_created = []
    headers = CSV.read(file.path)[0]

    unless headers.include?("first_name") && headers.include?("last_name")
      raise "Import Cancelled: Incorrect Required Headers"
    end

    CSV.foreach(file.path, headers: true) do |row|

      member_hash = row.to_hash 
      if member_hash["first_name"].nil? || member_hash["last_name"].nil?
        not_created << "row missing required first_name and last_name"
        next
      end

      member = Member.where(first_name: member_hash["first_name"], last_name: member_hash["last_name"])

      if member.empty?
        Member.create!(member_hash)
      else
        not_created << "cannot find member - #{member_hash["first_name"]} #{member_hash["last_name"]}"
      end
    end # end CSV.foreach
    return not_created
  end # end self.import(file)

  def self.import_update(file)
    not_updated =[]
    headers = CSV.read(file.path)[0]

    unless headers.include?("id")
      raise "Import Cancelled: Incorrect Required Headers"
    end

    CSV.foreach(file.path, headers: true) do |row|
      
      member_hash = row.to_hash 
      if member_hash["id"].nil?
        not_updated << "row missing required id number"
        next
      end        
      
      member = Member.where(id: member_hash["id"])

      if member.length == 1
        member.first.update(member_hash)
      else
        not_updated << "cannot find member - #{member_hash["first_name"]} #{member_hash["last_name"]}"
      end
    end # end CSV.foreach
    return not_updated
  end # end self.import(file)

  def self.options_for_zip_select
    joins(:primary_address).pluck(:zip).uniq.delete_if{|x| x.nil? || x.empty?}.sort.map { |e| [e, e] }
  end

  def self.options_for_sorted_by
    [
      ['Last Name (a-z)', 'name_asc'],
      ['Last Name (z-a)', 'name_desc'],
      ['Dues Last Paid (oldest first)', 'dues_asc'],
      ['Dues Last Paid (newest first)', 'dues_desc'],
      ['Zip Code', 'zip_asc'],
    ]
  end  

  def self.options_for_selection
    [
      ['Skip Mail', 'skipmail'],
      ['Custom Addressee', 'addressee'],
      ['Custom Greeting', 'greeting'],
    ]
  end  

  def full_name
    "#{first_name} #{last_name}"
  end

  def name_with_title
    ([title, first_name, last_name] - [nil, ""]).join(" ")
  end

  private
  def all_clubs_are_valid
    unless self.clubs.blank?
       self.clubs.each do |club|
          unless Setting.list_values("other_clubs").include?(club)
             errors.add(:clubs, "#{club} is not valid")
          end
       end
    end
   end  

  def set_date(date_string)
    return Date.today if date_string.nil?
    Date.parse(date_string)
  end  

end
