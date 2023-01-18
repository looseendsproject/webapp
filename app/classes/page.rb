class Page < Sanity::Resource
  attribute :_id, default: ""
  attribute :_type, default: ""
  attribute :name, default: ""
  attribute :path, default: ""
  attribute :body, default: []

  queryable
end