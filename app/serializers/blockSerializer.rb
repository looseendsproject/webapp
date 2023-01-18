class BlockSerializer
  class << self
    def call(...)
      new(...).call
    end
  end

  attr_reader :children

  def initialize(args)
    @children = args["children"]
  end

  def call
    children.map do |child| Span.new(
      _id: child["_id"],
      _type: child["_type"],
      tag: child["path"],
      name: child["name"],
      body: child["body"]
    )
    end
  end
end