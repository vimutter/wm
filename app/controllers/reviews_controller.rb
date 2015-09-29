class ReviewsController < ApplicationController

  def index
    respond_to do |format|
      format.html
      format.js do
        unless params[:id].present?
          @reviews = Wallmart.empty
        else
          @reviews = Wallmart.reviews(params[:id], params[:keywords])
        end
      end
    end
  end
end

