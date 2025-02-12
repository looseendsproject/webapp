# frozen_string_literal: true

class AssignmentUpdate < ApplicationRecord
  belongs_to :assignment
  belongs_to :user
end
