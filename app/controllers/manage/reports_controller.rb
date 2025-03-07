class Manage::ReportsController < Manage::ManageController
  # Add route for each report and link on dashboard

  def heard_about_us
    @description = 'Counts of user records by heard_about_us value'
    @columns = %w(heard_about_us count)
    @results = User.group(:heard_about_us).order('count_heard_about_us DESC').count(:heard_about_us)
    render 'show'
  end
end
