# XXX: test
class Api::TagsController < Api::BaseController
  def require_resources
    if params[:include_merged]
      @resources = Tag.all
    else
      @resources = Tag.active
    end
  end

  def require_resource
    @resource = Tag.find(params[:id])
  end

  def respond_with_resources_options
    {paginate: true}
  end
end
