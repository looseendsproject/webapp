# frozen_string_literal: true

# == Schema Information
#
# Table name: projects
#
#  id                                                :bigint           not null, primary key
#  can_publicize                                     :boolean
#  can_share_crafter_details                         :boolean          default(TRUE)
#  can_use_first_name                                :boolean          default(FALSE)
#  city                                              :string
#  country                                           :string
#  craft_type                                        :string
#  crafter_description                               :text
#  crafter_dominant_hand                             :string
#  crafter_name                                      :string
#  description                                       :text
#  dominant_hand(Dominant hand of the project owner) :string           default("unknown"), not null
#  group_project                                     :boolean          default(FALSE)
#  has_materials                                     :string
#  has_pattern                                       :string
#  has_smoke_in_home                                 :boolean          default(FALSE)
#  in_home_pets                                      :string
#  inbound_email_address                             :string
#  influencer                                        :boolean          default(FALSE)
#  joann_helped                                      :boolean          default(FALSE)
#  latitude                                          :float
#  longitude                                         :float
#  material_brand                                    :text
#  material_type                                     :string
#  more_details                                      :text
#  name                                              :string           not null
#  needs_attention                                   :string
#  no_cats                                           :boolean
#  no_dogs                                           :boolean
#  no_smoke                                          :boolean
#  phone_number                                      :string
#  postal_code                                       :string
#  press                                             :boolean          default(FALSE)
#  press_outlet                                      :string
#  press_region                                      :string
#  privacy_needed                                    :boolean          default(FALSE)
#  recipient_name                                    :string
#  state                                             :string
#  status                                            :string           default("PROPOSED"), not null
#  street                                            :string
#  street_2                                          :string
#  terms_of_use                                      :boolean
#  urgent                                            :boolean          default(FALSE)
#  created_at                                        :datetime         not null
#  updated_at                                        :datetime         not null
#  group_manager_id                                  :bigint
#  manager_id                                        :bigint
#  user_id                                           :bigint
#
# Indexes
#
#  index_projects_on_group_manager_id       (group_manager_id)
#  index_projects_on_inbound_email_address  (inbound_email_address) UNIQUE
#  index_projects_on_latitude               (latitude)
#  index_projects_on_longitude              (longitude)
#  index_projects_on_manager_id             (manager_id)
#  index_projects_on_user_id                (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (group_manager_id => finishers.id)
#  fk_rails_...  (manager_id => users.id)
#
require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  def setup
    @project = projects(:one)
  end

  test "All fixtures should be valid" do
    Project.find_each do |project|
      project.save
      assert_predicate(project, :valid?, "Project fixture is invalid. Errors: #{project.errors.inspect}")
    end
  end

  test "needing_attention scope" do
    Project.first.update(needs_attention: "manager_hold")
    assert_equal 1, Project.needing_attention.count

    Project.first.update(needs_attention: "")
    assert_equal 0, Project.needing_attention.count
  end

  test "finisher method returns finisher" do
    assert_not_nil @project.finisher
    assert_equal finishers(:knitter), @project.finisher
  end

  test "finisher method returns last finisher" do
    @project.assignments.create!(creator: User.new, finisher: finishers(:crocheter))
    assert_not_nil @project.finisher
    assert_equal finishers(:crocheter), @project.finisher
  end

  test "active_finisher method returns finisher" do
    assert_not_nil @project.active_finisher
    assert_equal finishers(:knitter), @project.active_finisher
  end

  test "ignore_inactive scope" do
    Project::STATUSES.each do |key, value|
      @project.update(status: value)
      if Project::INACTIVE_STATUSES.include?(key)
        assert_not_includes Project.ignore_inactive, @project.reload
      else
        assert_includes Project.ignore_inactive, @project.reload
      end
    end
  end

  test "inbound_email_address assignment" do
    p = Project.new
    refute p.inbound_email_address
    p.valid?
    assert_match /^project-\w{#{EmailAddressable::LENGTH}}@#{EmailAddressable::DESTINATION_HOST}/,
      p.inbound_email_address
  end

  test "Name update" do
    @project.name = "Updated Name"
    @project.save!

    assert_equal("Updated Name", @project.reload.name)
  end

  test "Valid phone number update" do
    @project.phone_number = "1231231234"
    @project.save!

    assert_equal("1231231234", @project.reload.phone_number)
  end

  test "Short phone number not allowed" do
    @project.phone_number = "123123123"

    assert_not_predicate(@project, :valid?, "Short phone number should not be allowed")
  end

  test "status defaults to PROPOSED if the project IS NOT missing information" do
    @project.status = nil
    @project.save!

    assert_equal("PROPOSED", @project.reload.status)
  end

  test "status defaults to PROPOSED if the project IS missing information" do
    @project.has_pattern = nil
    @project.status = nil
    @project.save!

    assert_equal("PROPOSED", @project.reload.status)
  end

  test "invalid status rejected" do
    @project.status = "invalid status"

    assert_not_predicate(@project, :valid?, "Invalid status should not be allowed")
  end

  test "needs_attention_option returns proper struct" do
    assert_equal [["Negative Sentiment", "negative_sentiment"],
      ["Finisher Unresponsive", "finisher_unresponsive"],
      ["Manager Hold", "manager_hold"],
      ["Completed", "completed"]],
      Project.needs_attention_options
  end

  test "missing_address_information? helper" do
    assert_not_predicate(@project, :missing_address_information?,
                         "Project fixture should not be missing address information")
    %i[street city state postal_code country].each do |field|
      @project[field] = nil

      assert_predicate(@project, :missing_address_information?,
                       "Project should be missing address information when #{field} is nil")
    end
  end

  test "missing_information? helper" do
    assert_not_predicate(@project, :missing_information?, "Project fixture should not be missing information")
    %i[description phone_number has_pattern material_type].each do |field|
      @project[field] = nil

      assert_predicate(@project, :missing_information?, "Project should be missing information when #{field} is nil")
    end
  end

  test "updated_at timestamp updated when a project note is added" do
    original_updated_at = @project.updated_at
    @project.notes.create(user: User.new, text: "here's a new note")

    assert_not_equal(original_updated_at, @project.updated_at)
  end

  test "updated_at timestamp updated when a project note is updated" do
    note = @project.notes.create(user: User.new, text: "here's a new note")
    original_updated_at = @project.updated_at
    note.update(text: "updated note description")

    assert_not_equal(original_updated_at, @project.updated_at)
  end

  test "updated_at timestamp updated when an assignment is added" do
    original_updated_at = @project.updated_at
    @project.assignments.create(creator: User.new, finisher: finishers(:crocheter))

    assert_not_equal(original_updated_at, @project.updated_at)
  end

  test "updated_at timestamp updated when an assignment is updated" do
    assignment = @project.assignments.create(creator: User.new, finisher: finishers(:crocheter))
    original_updated_at = @project.updated_at
    assignment.update(started_at: DateTime.now)

    assert_not_equal(original_updated_at, @project.updated_at)
  end

  test "has messages" do
    assert_nothing_raised { @project.messages }
  end

  test "responds to finisher_notes" do
    assignment = @project.assignments.create(creator: User.new, finisher: finishers(:crocheter))
    assignment.notes.create!(sentiment: "going_well",
      text: "Here's some text", user_id: finishers(:crocheter).id)
    assert_equal "Here's some text", @project.finisher_notes.first.text
  end

  test "acts as EmailAddressable" do
    assert Project.method_defined? :inbound_email_address
    assert @project.inbound_email_address
  end
end
