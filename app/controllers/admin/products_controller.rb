class Admin::ProductsController < Admin::AdminController
  def index
    @products = Product.all
  end

  def show
    @product = Product.find(params[:id])
  end

  def edit
    @product = Product.find(params[:id])
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to [:admin, @product]
    else
      render "new"
    end
  end

  def update
    product = Product.find(params[:id])
    product.update!(product_params)
    redirect_to product
  end

  private

  def product_params
    params.require(:product).permit(:name, :description)
  end

end
