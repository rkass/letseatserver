module Api
  module V1
    class SessionController < Api::V1::ApiController
      def create
        print "creating"
      end
      def destroy
        print "destroying"
      end 
    end
  end
end
