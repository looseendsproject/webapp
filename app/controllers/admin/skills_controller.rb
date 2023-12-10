class Admin::SkillsController < Admin::AdminController
  def index
    @skills = Skill.sorted_by_popularity
  end

  def show
    @skill = Skill.find(params[:id])
  end

  def edit
    @skill = Skill.find(params[:id])
  end

  def new
    @skill = Skill.new
  end

  def create
    @skill = Skill.new(skill_params)
    if @skill.save
      redirect_to [:admin, @skill]
    else
      render "new"
    end
  end

  def update
    @skill = Skill.find(params[:id])
    @skill.update!(skill_params)
    redirect_to [:admin, @skill]
  end

  private

  def skill_params
    params.require(:skill).permit(:name, :description, :position)
  end

end
