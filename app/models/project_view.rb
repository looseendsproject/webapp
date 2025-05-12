# == Schema Information
#
# Table name: project_views
#
#  id         :bigint           not null, primary key
#  name       :text             not null
#  query      :jsonb            not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
class ProjectView < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :query, presence: true
  validates :name, uniqueness: { scope: :user_id }
  validate :has_valid_query

  private

  def has_valid_query
    # Check if the query is a valid JSON object
    query_json = JSON.parse(query.to_json)

    if query_json.is_a?(Array)
      # Check if the query contains only valid keys
      valid_keys = %w[field value]
      query_json.each do |item|
        invalid_keys = item.keys - valid_keys

        if item.keys != valid_keys
          errors.add(:query,
                     "malformed: keys:[#{item.keys.join(", ")}] invalid:[#{invalid_keys.join(", ")}]")
        end
      end
    else
      errors.add(:query, "must be a JSON array")
      false
    end
  rescue JSON::ParserError
    errors.add(:query, "must be a valid JSON object")
    false
  end
end
