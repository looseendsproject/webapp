class Admin::FinishersController < Admin::AdminController
  def index
    @finishers = Finisher.paginate(page: params[:page])
  end

  def edit
    @finisher = Finisher.find(params[:id])
  end

  def update
    @finisher = Finisher.find(params[:id])
    @finisher.update!(finisher_params)
    redirect_to [:admin, @finisher]
  end

  private

  def finisher_params
    params.require(:finisher).permit(:approved)
  end

end
