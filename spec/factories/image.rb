FactoryGirl.define do
  factory :image do
    source_url "http://localhost:3000/test_source/foo.png"
    comment "awesome"
    sha "8cab337c688e4f4f4965153b133df458a8992dd7"
    storage_path "/2d/d7/8cab337c688e4f4f4965153b133df458a8992dd7.png"
    duplication_id nil
  end
end
