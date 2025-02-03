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
    @project.save!
    assert_equal('Updated Name', @project.reload.name)
  end

  test 'Valid phone number update' do
    @project.phone_number = '1231231234'
    @project.save!
    assert_equal('1231231234', @project.reload.phone_number)
  end

  test 'Short phone number not allowed' do
    @project.phone_number = '123123123'
    refute(@project.valid?, 'Short phone number should not be allowed')
  end

  test 'status defaults to proposed if the project IS NOT missing information' do
    @project.status = nil
    @project.save!
    assert_equal('proposed', @project.reload.status)
  end

  test 'status defaults to drafted if the project IS missing information' do
    @project.has_pattern = nil
    @project.status = nil
    @project.save!
    assert_equal('drafted', @project.reload.status)
  end

  test 'invalid status rejected' do
    @project.status = 'invalid status'
    refute(@project.valid?, 'Invalid status should not be allowed')
  end

  test 'missing_address_information? helper' do
    refute(@project.missing_address_information?, 'Project fixture should not be missing address information')
    [:street, :city, :state, :postal_code, :country].each do |field|
      @project[field] = nil
      assert(@project.missing_address_information?, "Project should be missing address information when #{field} is nil")
    end
  end

  test 'missing_information? helper' do
    refute(@project.missing_information?, 'Project fixture should not be missing information')
    [:description, :phone_number, :has_pattern, :material_type].each do |field|
      @project[field] = nil
      assert(@project.missing_information?, "Project should be missing information when #{field} is nil")
    end
  end
end