require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  def setup
    @project = projects(:one)
  end

  test "All fixtures should be valid" do
    Project.all.each do |project|
      assert(project.valid?, "Project fixture is invalid. Errors: #{project.errors.inspect}")
    end
  end

  test 'Name update' do
    @project.name = 'Updated Name'
    @project.save
    assert_equal('Updated Name', @project.reload.name)
  end

  test 'Valid phone number update' do
    @project.phone_number = '1231231234'
    @project.save
    assert_equal('1231231234', @project.reload.phone_number)
  end

  test 'Short phone number not allowed' do
    @project.phone_number = '123123123'
    @project.save
    refute(@project.valid?, 'Short phone number should not be allowed')
  end
end