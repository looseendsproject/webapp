class FinishersController < AuthenticatedController

  before_action :store_user_location!, if: :storable_location?
  before_action :authenticate_user!, except: [:show]

  def show
    @finisher = current_user.finisher
  end

  def new
    if current_user.finisher
      redirect_to edit_profile_finisher_path
    end
    @finisher = Finisher.new(chosen_name: current_user.first_name + ' ' + current_user.last_name)
    @finisher.assessments = Skill.sorted_by_popularity.map { |skill| Assessment.new(skill_id: skill.id, rating: 0)}
  end

  def edit_skills
    @finisher = current_user.finisher
    Skill.sorted_by_popularity.each do |skill|
      if (!@finisher.assessments.where(skill_id: skill.id).any?)
        @finisher.assessments << Assessment.new(skill_id: skill.id, rating: 0)
      end
    end
  end

  def edit_profile
    @finisher = current_user.finisher
  end
  def edit_favorites
    @finisher = current_user.finisher
  end
  def edit_address
    @finisher = current_user.finisher
  end

  def create
    @finisher = Finisher.new(finisher_params.merge(has_taken_ownership_of_profile: true))
    @finisher.user = current_user
    if @finisher.save
      redirect_to finisher_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @finisher = current_user.finisher

    if @finisher.update(finisher_params.merge(has_taken_ownership_of_profile: true))
      redirect_to finisher_path
    else
      if finisher_params[:chosen_name]
        render :edit_profile, status: :unprocessable_entity
      elsif finisher_params[:country]
        render :edit_address, status: :unprocessable_entity
      elsif finisher_params[:other_skills]
        render :edit_skills, status: :unprocessable_entity
      elsif finisher_params[:other_favorites]
        render :edit_favorites, status: :unprocessable_entity
      end

    end
  end

  def destroy
    @finisher = current_user.finisher
    if (params[:finished_project_id])
      finished_project_image = @finisher.finished_projects.find(params[:finished_project_id])
      finished_project_image.purge
      redirect_to finisher_path
    end
  end


  private

  def finisher_params
    params.require(:finisher).permit(
      :chosen_name,
      :pronouns,
      :phone_number,
      :description,
      :street,
      :street_2,
      :city,
      :state,
      :country,
      :postal_code,
      :picture,
      :other_skills,
      :other_favorites,
      :dislikes,
      :social_media,
      :can_publicize,
      :dominant_hand,
      :no_smoke,
      :no_cats,
      :no_dogs,
      :has_smoke_in_home,
      :terms_of_use,
      :has_workplace_match,
      :workplace_name,
      in_home_pets: [],
      append_finished_projects: [],
      product_ids: [],
      assessments_attributes: [:id, :skill_id, :rating, :description, :user_id])
  end

end
