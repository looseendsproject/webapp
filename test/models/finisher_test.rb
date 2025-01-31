require 'test_helper'

class FinisherTest < ActiveSupport::TestCase
  test 'Fixtures should be valid' do
    Finisher.all.each do |finisher|
      assert finisher.valid?, "Finisher #{finisher.id} is invalid: #{finisher.errors.full_messages.to_sentence}"
    end
  end

  test 'Has many skills, ordered by position' do
    finisher = finishers(:crocheter)
    assert_equal 2, finisher.skills.count
    assert_equal [2, nil], finisher.skills.map(&:position)
  end

end