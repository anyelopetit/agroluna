# frozen_string_literal: true

# Keppler
module CloneRecord
  extend ActiveSupport::Concern

  # Class Methods
  module ClassMethods
    def clone_record(id)
      object = name.constantize.find_by(id: id)
      object.dup
    end
  end
end
