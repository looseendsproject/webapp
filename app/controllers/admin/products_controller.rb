# frozen_string_literal: true

module Admin
  class ProductsController < Admin::AdminController
    def index
      @products = Product.order(:name)
      @title = "Loose Ends - Admin - Products"
    end

    def show
      @product = Product.find(params[:id])
      @title = "Loose Ends - Admin - Products - #{@product.name}"
    end

    def new
      @product = Product.new
      @title = "Loose Ends - Admin - New Product"
    end

    def edit
      @product = Product.find(params[:id])
      @title = "Loose Ends - Admin - Edit Product - #{@product.name}"
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
      @product = Product.find(params[:id])
      @product.update!(product_params)
      redirect_to [:admin, @product]
    end

    private

    def product_params
      params.require(:product).permit(:name, :description)
    end
  end
end
