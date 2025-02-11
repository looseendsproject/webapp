class ProjectNote < ApplicationRecord
  belongs_to :project, touch: true
  belongs_to :user

end
