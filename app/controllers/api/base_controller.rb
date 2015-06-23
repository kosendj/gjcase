class Api::BaseController < ActionController::Base
  include Garage::ControllerHelper
  include Garage::RestfulActions

  rescue_from ActiveRecord::RecordNotFound do
    render status: 404, json: {"error": {"status": 404, "message": "Not Found"}}
  end

  rescue_from ActiveRecord::RecordInvalid do
    render status: 422, json: {"error": {"status": 422, "message": "Not Found"}}
  end
end
