class ReglinkController < ApplicationController

  def withLink
    render js: => "alert('Hello World');"
  end

end
