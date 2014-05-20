class ReglinkController < ApplicationController


  def withLink
    respond_to do |format|
      format.js { render :js => "alert('helloworld');" }
    end
  end

end
