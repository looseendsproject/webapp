class PagesController < ApplicationController

  def show
    @page = Page.where(path: params[:page_path], result_wrapper: PageSerializer).first
  end
end