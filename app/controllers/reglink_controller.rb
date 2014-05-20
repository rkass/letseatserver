class ReglinkController < ApplicationController

  javascript_include_tag "open_app" 

  def withLink
    respond_to do |format|
      format.js { render :js => "helloWorld();" }
    end
  end

end
