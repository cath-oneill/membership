class Member < ActiveRecord::Base

  include Member::Export 
  include Member::Import

  has_many :payments,   dependent: :destroy
  has_many :notes,      dependent: :destroy
  has_many :addresses,  dependent: :destroy
  has_one  :primary_address, :class_name => "Address"

  delegate :address1, :address2, :city, :state, :zip, :skip_mail, to: :primary_address, allow_nil: true

  validates :first_name, :last_name, :presence => true

  before_save :check_for_duplicate_member

  acts_as_taggable_on :tags

  filterrific(
    default_filter_params: { sorted_by: 'name_asc' },
    available_filters: [
      :search_query,
      :sorted_by,
      :zip_select,
      :last_dues_paid_gte,
      :mail_select,
      :tag_select
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

  scope :zip_select, lambda { |zip|
    joins(:primary_address).where{primary_address.zip == zip.to_s}
  }

  scope :mail_select, lambda { |keyword|
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

  scope :tag_select, lambda {|tag|
    tagged_with(tag)
  }


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

  def self.options_for_mail_select
    [
      ['Skip Mail', 'skipmail'],
      ['Custom Addressee', 'addressee'],
      ['Custom Greeting', 'greeting'],
    ]
  end  

  def self.options_for_tag_select
    ActsAsTaggableOn::Tag.all.map { |tag| [tag.name, tag.name] }
  end

  def full_name
    ([first_name, middle_initial, last_name] - [nil, ""]).join(" ")
  end

  def name_with_title
    ([title, first_name, middle_initial, last_name] - [nil, ""]).join(" ")
  end

  def middle_initial
    return nil if middle_name.nil?
    middle_name[0] + "."
  end

  def self.get_name_by_id(id)
    Member.find(id).full_name
  end

  private 

  def check_for_duplicate_member
    first, middle, last, i = first_name, middle_name, last_name, id
    if middle.blank? && Member.where{(first_name =~ "%#{first}%") & (last_name =~ "#{last}%") & (id != i)}.present?
      errors.add("Another member of same name")
      return false
    elsif Member.where{(first_name =~ "%#{first}%") & (middle_name =~ "%#{middle}%") & (last_name =~ "#{last}%") & (id != i)}.present?
      errors.add("Another member of same name") 
      return false
    else
      return true
    end
  end

end
