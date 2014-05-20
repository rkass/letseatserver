javascript_include_tag "open_app"

class ReglinkController < ApplicationController

  def withLink
    respond_to do |format|
      format.js { render :js => "helloWorld();" }
    end
  end

end
