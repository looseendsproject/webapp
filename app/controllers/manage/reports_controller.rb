class Manage::ReportsController < Manage::ManageController
  # Add route for each report and link on dashboard

  def heard_about_us
    @description = 'Counts of user records by heard_about_us value'
    @result = ActiveRecord::Base.connection.execute("
      SELECT heard_about_us, COUNT(*) AS count
      FROM users
      GROUP BY heard_about_us
      ORDER BY count DESC
    ")
    render 'show'
  end
end
