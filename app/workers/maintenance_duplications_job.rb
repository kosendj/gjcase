class MaintenanceDuplicationsJob
  include Sidekiq::Worker

  def perform
    Image.unduplicated.distinct.pluck(:sha).each {|_| imgs = Image.where(sha: _).order(id: :asc).pluck(:id); parent = imgs.shift; Image.where(id: imgs).update_all(duplication_id: parent) }
  end
end
