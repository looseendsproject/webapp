# frozen_string_literal: true

class Note < ApplicationRecord
  belongs_to :notable, polymorphic: true

  before_create :set_visibility

  private

    def set_visibility
      case notable.class.to_s
      when "Project"
        self.visibility = "manager"
      when "Assignment"
        self.visibility = "finisher"
      else
        raise NotImplementedError
      end
    end
end
