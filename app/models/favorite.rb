# frozen_string_literal: true

# == Schema Information
#
# Table name: favorites
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  finisher_id :bigint
#  product_id  :bigint
#
# Indexes
#
#  index_favorites_on_finisher_id  (finisher_id)
#  index_favorites_on_product_id   (product_id)
#
class Favorite < ApplicationRecord
  belongs_to :product
  belongs_to :finisher

  validates :product, uniqueness: { scope: :finisher }
end
