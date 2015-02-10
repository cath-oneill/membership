class Member < ActiveRecord::Base
  has_many :payments
  has_many :notes

  serialize :clubs, Array

  validates :first_name, :last_name, :presence => true
  validate  :all_clubs_are_valid

  filterrific(
    default_filter_params: { sorted_by: 'name_asc' },
    available_filters: [
      :search_query,
      :sorted_by,
      :by_zip_code,
      :last_dues_paid_gte
    ]
  )

  # default for will_paginate
  self.per_page = 10

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? :desc : :asc
    case sort_option.to_s
    when /^zip_/
      order(zip: direction)
    when /^dues_/
      order(dues_paid: direction)
    when /^name_/
      order(last_name: direction)
    else
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :search_query, lambda { |query|
    return nil  if query.blank?
    # condition query, parse into individual keywords
    terms = query.downcase.split(/\s+/)
    # replace "*" with "%" for wildcard searches,
    # append '%', remove duplicate '%'s
    terms = terms.map { |e|
      (e.gsub('*', '%') + '%').gsub(/%+/, '%')
    }
    # configure number of OR conditions for provision
    # of interpolation arguments. Adjust this if you
    # change the number of OR conditions.
    num_or_conditions = 2
    where(
      terms.map { |term|
          "(LOWER(members.first_name) LIKE ? OR LOWER(members.last_name) LIKE ?)"
      }.join(' AND '),
      *terms.map { |e| [e] * num_or_conditions }.flatten
    )
  }

  scope :last_dues_paid_gte, lambda { |ref_date|
    where('members.dues_paid >= ?', ref_date)
  }

  scope :by_zip_code, lambda { |zip|
    where(zip: zip.to_s)
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
    pluck(:zip).uniq.map { |e| [e, e] }
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

  def full_name
    "#{first_name} #{last_name}"
  end

  def name_with_title
    ([title, first_name, last_name] - [nil, ""]).join(" ")
  end

  def calculated_mail_name
    if mail_name.blank?
      return name_with_title
    else
      return mail_name
    end
  end

  def calculated_greeting
    if greeting.blank?
      return first_name
    else
      return greeting
    end
  end

  private
  def all_clubs_are_valid
    all_clubs = Setting.where(lookup: "other_clubs").first.value
    unless self.clubs.blank?
       self.clubs.each do |club|
          unless all_clubs.include?(club)
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
