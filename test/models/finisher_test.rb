# frozen_string_literal: true

# == Schema Information
#
# Table name: finishers
#
#  id                             :bigint           not null, primary key
#  admin_notes                    :text
#  approved_at                    :datetime
#  can_publicize                  :boolean
#  check_in_interval              :integer
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

  test "phone number validation allows blanks (b/c some prod data is that way)" do
    f = Finisher.first

    assert_predicate f, :valid?
    f.phone_number = ''

    assert_predicate f, :valid?
    f.phone_number = '12345678' # too short

    refute f.valid?
  end

  test "Has many skills, ordered by position" do
    finisher = finishers(:crocheter)

    assert_equal 2, finisher.skills.count
    assert_equal [2, nil], finisher.skills.map(&:position)
  end

  test "has messages" do
    finisher = finishers(:crocheter)

    assert_equal finisher.name, finisher.messages.first.description
  end

  test "inbound_email_address assignment" do
    f = Finisher.new

    refute f.inbound_email_address
    f.valid?

    assert_match /finisher-\w{#{EmailAddressable::LENGTH}}@#{EmailAddressable::DESTINATION_HOST}/, f.inbound_email_address
  end

  test "send welcome records Message" do
    finisher = finishers(:knitter)
    finisher.send_welcome_message

    assert_equal "Loose Ends Project Account Created - Next Steps...",
      finisher.messages.last.email.subject
  end

  test "send profile_complete records Message" do
    finisher = finishers(:knitter)
    finisher.send_profile_complete_message

    assert_equal "Welcome, Loose Ends Finisher!",
      finisher.messages.last.email.subject
  end

  test "An existing finisher with 6 finished projects is valid" do
    image = Rack::Test::UploadedFile.new(File.join(ActionDispatch::IntegrationTest.file_fixture_path, 'tiny.jpg'), 'image/jpeg')

    finisher = finishers(:crocheter)
    finisher.append_finished_projects = [image] * 6
    finisher.save!(validate: false)

    assert_predicate finisher, :valid?
    assert_equal 6, finisher.finished_projects.count
  end

  test "Adding a 6th finished project raises error" do
    image = Rack::Test::UploadedFile.new(File.join(ActionDispatch::IntegrationTest.file_fixture_path, 'tiny.jpg'), 'image/jpeg')

    finisher = finishers(:crocheter)
    finisher.append_finished_projects = [image] * 5
    finisher.save!(validate: false)

    finisher.append_finished_projects = [image]

    assert_not finisher.valid?
    assert_includes finisher.errors[:finished_projects], "too many files attached (maximum is 5 files, got 6)"
  end

  test "Removing a finished project from a user with too many is allowed" do
    image = Rack::Test::UploadedFile.new(File.join(ActionDispatch::IntegrationTest.file_fixture_path, 'tiny.jpg'), 'image/jpeg')

    finisher = finishers(:crocheter)
    finisher.append_finished_projects = [image] * 7
    finisher.save!(validate: false)

    last_image = finisher.finished_projects.last
    last_image.purge # remove the last image

    assert finisher.reload.valid?
  end
end
