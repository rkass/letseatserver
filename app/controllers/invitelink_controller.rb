class InvitelinkController < ApplicationController

  def withlink
    render do |page|
      page.html {}
      page.js {}
    end 
  end 

end
