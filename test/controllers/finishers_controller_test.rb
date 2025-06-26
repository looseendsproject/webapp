# frozen_string_literal: true

require "test_helper"

class FinishersControllerTest < ActionController::TestCase
  def setup
    @user = users(:new)

    # POST :create
    @profile_params = {
      "finisher" => {
        "chosen_name" => "Jello",
        "pronouns" => "they/them",
        "phone_number" => "7815551212",
        "description" => "Knitting steampunk afghans since 1992",
        "social_media" => "",
        "has_workplace_match" => "false",
        "workplace_name" => "",
        "can_publicize" => "0",
        "emergency_contact_name" => "",
        "emergency_contact_relation" => "",
        "emergency_contact_phone_number" => "",
        "emergency_contact_email" => "",
        "terms_of_use" => "1"
      }
    }

    # PATCH :update
    @address_params = {
      "finisher" => {
        "country" => "US",
        "street" => "123 Main St",
        "street_2" => "",
        "city" => "Anytown",
        "state" => "WA",
        "postal_code" => "12345"
      }
    }

    # PATCH :update
    @skills_params = {
      "finisher" => {
        "assessments_attributes" => {
          "0" => { "skill_id" => "1", "rating" => "2", "description" => "quilting" }
        },
        "other_skills" => "",
        "dominant_hand" => "Lefty",
        "in_home_pets" => [""],
        "has_smoke_in_home" => "0",
        "no_smoke" => "0",
        "no_cats" => "0",
        "no_dogs" => "0"
      }
    }

    # PATCH :update
    @favorites_params = {
      "finisher" => {
        "product_ids" => ["", "1", "3"],
        "other_favorites" => "",
        "append_finished_projects" => [""],
        "dislikes" => ""
      }
    }

    sign_in @user
  end

  test "profile flow sends welcome & profile_complete messages" do
    post :create, params: @profile_params

    assert_redirected_to finisher_path
    assert_equal "Loose Ends Project Account Created - Next Steps...", ActionMailer::Base.deliveries.last.subject

    patch :update, params: @address_params

    assert_redirected_to finisher_path
    assert_equal "Loose Ends Project Account Created - Next Steps...", ActionMailer::Base.deliveries.last.subject

    patch :update, params: @skills_params

    assert_redirected_to finisher_path
    assert_equal "Loose Ends Project Account Created - Next Steps...", ActionMailer::Base.deliveries.last.subject

    patch :update, params: @favorites_params

    assert_redirected_to finisher_path
    assert_equal "Welcome, Loose Ends Finisher!", ActionMailer::Base.deliveries.last.subject
  end

  test "can update if the finisher has volunteer time off" do
    post :create, params: @profile_params

    finisher = Finisher.find_by(chosen_name: @profile_params["finisher"]["chosen_name"])

    assert_not_nil(finisher)

    @profile_params["finisher"].merge!("has_volunteer_time_off" => "true")

    patch :update, params: @profile_params.merge("id" => finisher.id)

    finisher.reload

    assert(finisher.has_volunteer_time_off)
  end

  test "can remove finished project image over limit" do
    finisher = finishers(:crocheter)
    finisher.append_finished_projects = [fixture_file_upload("tiny.jpg")] * 15
    finisher.save!(validate: false)

    sign_in finisher.user

    post :destroy, params: { finished_project_id: finisher.finished_projects.first.id }
    assert_redirected_to finisher_path

    finisher.reload
    assert_equal 14, finisher.finished_projects.count
  end
end
