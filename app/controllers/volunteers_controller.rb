class VolunteersController < ApplicationController

  before_action :store_user_location!, if: :storable_location?
  before_action :authenticate_user!, except: [:index, :show]

  def show
    @volunteer = current_user.volunteer
  end

  def new
    if current_user.volunteer
      redirect_to edit_volunteer_path
    end
    @volunteer = Volunteer.new
    @volunteer.assessments = Skill.all.map { |skill| Assessment.new(skill_id: skill.id, rating: 0)}
  end

  def edit
    @volunteer = current_user.volunteer
    Skill.all.each do |skill|
      if (!@volunteer.assessments.where(skill_id: skill.id).any?)
        @volunteer.assessments << Assessment.new(skill_id: skill.id, rating: 0)
      end
    end
  end

  def create
    @volunteer = Volunteer.new(volunteer_params)
    @volunteer.user = current_user
    if @volunteer.save
      redirect_to volunteer_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @volunteer = current_user.volunteer
    if @volunteer.update(volunteer_params)
      redirect_to volunteer_path
    else
      render :edit, status: :unprocessable_entity
    end
  end


  private

  def volunteer_params
    params.require(:volunteer).permit(:description, :street, :street_2, :city, :state, :country, :postal_code, :picture, :other_skills, :other_favorites, :dislikes, :social_media, :can_publicize, :dominant_hand, :no_smoke, :no_pets, :terms_of_use, product_ids: [], assessments_attributes: [:id, :skill_id, :rating, :description, :user_id])
  end

end
