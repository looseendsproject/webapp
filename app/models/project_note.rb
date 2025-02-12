# frozen_string_literal: true

class ProjectNote < ApplicationRecord
  belongs_to :project
  belongs_to :user
end
