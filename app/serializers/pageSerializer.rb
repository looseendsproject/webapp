class PageSerializer
  class << self
    def call(...)
      new(...).call
    end
  end

  attr_reader :results

  def initialize(args)
    @results = args["result"]
  end

  def call
    raise results.first
    results.map do |result| Page.new(
      _id: result["_id"],
      _type: result["_type"],
      path: result["path"],
      name: result["name"],
      body: result["body"]
    )
    end
  end
end