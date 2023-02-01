class VolunteersController < ApplicationController
  def show
    @volunteer = current_user.volunteer
  end

  def new
    @volunteer = current_user.build_volunteer
    @volunteer.assessments = Skill.all.map { |skill| Assessment.new(skill_id: skill.id, rating: 0)}
  end

  def edit
    @volunteer = current_user.volunteer
    @unassessed_skills = Skill.where.not(id: @volunteer.skills.pluck(:id) )
    if (@unassessed_skills.any?)
      @unassessed_skills.each do |skill|
        @volunteer.assessments.build( {skill_id: skill.id, rating: 0})
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
    params.require(:volunteer).permit(:description, :contact_info, :availability, :picture, assessments_attributes: [:id, :skill_id, :rating, :description, :user_id])
  end

end
