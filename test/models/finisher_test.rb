# frozen_string_literal: true

# == Schema Information
#
# Table name: finishers
#
#  id                             :bigint           not null, primary key
#  admin_notes                    :text
#  approved_at                    :datetime
#  can_publicize                  :boolean
#  chosen_name                    :string
#  city                           :string
#  country                        :string
#  description                    :text             not null
#  dislikes                       :text
#  dominant_hand                  :string
#  emergency_contact_email        :string
#  emergency_contact_name         :string
#  emergency_contact_phone_number :string
#  emergency_contact_relation     :string
#  has_completed_profile          :boolean          default(FALSE)
#  has_smoke_in_home              :boolean          default(FALSE)
#  has_taken_ownership_of_profile :boolean          default(FALSE)
#  has_volunteer_time_off         :boolean
#  has_workplace_match            :boolean
#  in_home_pets                   :string
#  inbound_email_address          :string
#  joined_on                      :date
#  latitude                       :float
#  longitude                      :float
#  no_cats                        :boolean
#  no_dogs                        :boolean
#  no_smoke                       :boolean
#  other_favorites                :text
#  other_skills                   :text
#  phone_number                   :string
#  postal_code                    :string
#  pronouns                       :string
#  social_media                   :text
#  state                          :string
#  street                         :string
#  street_2                       :string
#  terms_of_use                   :boolean
#  unavailable                    :boolean          default(FALSE)
#  workplace_name                 :string
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  user_id                        :bigint           not null
#
# Indexes
#
#  index_finishers_on_inbound_email_address  (inbound_email_address) UNIQUE
#  index_finishers_on_joined_on              (joined_on)
#  index_finishers_on_latitude               (latitude)
#  index_finishers_on_longitude              (longitude)
#  index_finishers_on_user_id                (user_id)
#
require "test_helper"

class FinisherTest < ActiveSupport::TestCase
  test "Fixtures should be valid" do
    Finisher.find_each do |finisher|
      assert_predicate finisher, :valid?,
                       "Finisher #{finisher.id} is invalid: #{finisher.errors.full_messages.to_sentence}"
    end
  end

  test "Has many skills, ordered by position" do
    finisher = finishers(:crocheter)

    assert_equal 2, finisher.skills.count
    assert_equal [2, nil], finisher.skills.map(&:position)
  end

  test "has messages" do
    assert_equal 'email/2025032345337', finishers(:crocheter).messages.first.description
  end

  test "inbound_email_address assignment" do
    f = Finisher.new
    refute f.inbound_email_address
    f.valid?
    assert_match /Finisher-\w{#{EmailAddressable::LENGTH}}@#{EmailAddressable::DESTINATION_HOST}/, f.inbound_email_address
  end
end
