module Api
  module V1
    class BaseApiController < ApplicationController
      before_action :authenticate_user
    end
  end
end
