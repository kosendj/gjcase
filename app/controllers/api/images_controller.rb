class Api::ImagesController < Api::BaseController
  def require_resources
    if params[:include_duplications]
      @resources = Image.all
    else
      @resources = Image.unduplicated
    end

    if params[:tags]
      # XXX:
      tag_queries = [*params[:tags]]
      tag_ids = Tag.where(id: tag_queries.grep(/\A[0-9]+\z/)).pluck(:id) \
              + Tag.where(name: tag_queries).pluck(:id)
      image_ids = TagAssignment.where(tag_id: tag_ids).pluck(:image_id)
      @resources = @resources.where(id: image_ids).page(params[:page])
    end
  end

  def require_resource
    @resource = Image.find(params[:id])
  end

  def respond_with_resources_options
    {paginate: true}
  end
end
