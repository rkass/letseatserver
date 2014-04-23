class Restaurant < ActiveRecord::Base
belongs_to :invitation
serialize :types_list
serialize :votes
end
