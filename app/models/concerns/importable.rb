module Importable
  extend ActiveSupport::Concern

  module ClassMethods  

    def check_headers(file, *required_headers)
      headers = CSV.read(file.path)[0].map{|h| h.parameterize.underscore}

      if (required_headers - headers).present?
        raise "Import Cancelled: Incorrect Required Headers"
      end
    end

    def create_hash(row)
      hash = {}
      row.each do |pair|
         key = pair[0].parameterize.underscore
         value = pair[1].try(:strip)
         hash[key] = value
      end
      hash
    end

    def hash_has_required_fields?(hash, *required_headers)
      required_headers.each do |h|
        if hash[h].nil?
          return false
        end
      end
      true
    end

  end

end