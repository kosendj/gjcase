class Api::BaseController < ActionController::Base
  include Garage::ControllerHelper
  include Garage::RestfulActions
end
