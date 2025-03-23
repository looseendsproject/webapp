# frozen_string_literal: true

# == Schema Information
#
# Table name: messages
#
#  id               :bigint           not null, primary key
#  description      :string
#  last_edited_by   :integer
#  messageable_type :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  messageable_id   :bigint
#
# Indexes
#
#  index_messages_on_messageable                          (messageable_type,messageable_id)
#  index_messages_on_messageable_type_and_messageable_id  (messageable_type,messageable_id)
#
class Message < ApplicationRecord
  belongs_to :messageable, polymorphic: true
  has_rich_text :content

  def email
    Mail.from_source content.to_plain_text
  end
end
