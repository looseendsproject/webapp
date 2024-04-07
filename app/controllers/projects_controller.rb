class ProjectsController < AuthenticatedController

  before_action :store_user_location!, if: :storable_location?

  before_action :get_project, :only => [
    :show,
    :edit_address,
    :edit_basics,
    :edit_crafter,
    :edit_project,
    :update,
    :destroy
  ]

  def show
  end

  def edit_address
  end
  def edit_basics
  end
  def edit_crafter
  end
  def edit_project
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    @project.user = current_user
    if @project.save
      redirect_to @project
    else
      render "new"
    end
  end

  def update
    if @project.update(project_params)
      redirect_to @project
    else
      render 'edit_basics'
    end
  end

  def destroy
    if (params[:project_image_id])
      project_image = @project.project_images.find(params[:project_image_id])
      project_image.purge
      redirect_to @project
    end

    if (params[:material_image_id])
      material_image = @project.material_images.find(params[:material_image_id])
      material_image.purge
      redirect_to @project
    end

    if (params[:crafter_image_id])
      crafter_image = @project.crafter_images.find(params[:crafter_image_id])
      crafter_image.purge
      redirect_to @project
    end

    if (params[:pattern_file_id])
      pattern_file = @project.pattern_files.find(params[:pattern_file_id])
      pattern_file.purge
      redirect_to @project
    end
  end

  private

  def project_params
    params.require(:project).permit(
      :name,
      :phone_number,
      :description,
      :more_details,
      :status,
      :street,
      :street_2,
      :city,
      :state,
      :country,
      :postal_code,
      :craft_type,
      :has_pattern,
      :material_type,
      :crafter_name,
      :crafter_description,
      :crafter_dominant_hand,
      :recipient_name,
      :can_publicize,
      :terms_of_use,
      :no_smoke,
      :no_cats,
      :no_dogs,
      :has_smoke_in_home,
      in_home_pets: [],
      append_crafter_images: [],
      append_project_images: [],
      append_pattern_files: [],
      append_material_images: []
    )
  end

  def get_project
    @project = current_user.projects.find_by_id(params[:id])
    redirect_to :root if !@project
  end


end
