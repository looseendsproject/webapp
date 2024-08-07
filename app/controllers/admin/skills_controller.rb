class Admin::SkillsController < Admin::AdminController
  def index
    @skills = Skill.sorted_by_popularity
    @title = "Loose Ends - Admin - Skills"
  end

  def show
    @skill = Skill.find(params[:id])
    @title = "Loose Ends - Admin - Skills - " + @skill.name
  end

  def edit
    @skill = Skill.find(params[:id])
    @title = "Loose Ends - Admin - Edit Skill - " + @skill.name
  end

  def new
    @skill = Skill.new
    @title = "Loose Ends - Admin - New Skill"
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
