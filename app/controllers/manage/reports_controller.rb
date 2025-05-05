class Manage::ReportsController < Manage::ManageController

  # Add route for each report and link on dashboard
  # @results is a 2-D array [[col1, col2, col3], [col1, col2, col3],...]
  # if you're displaying a table using render 'show'

  def heard_about_us
    @description = 'Counts of user records by heard_about_us value'
    @columns = %w(heard_about_us count)
    @results = User.group(:heard_about_us).order('count_heard_about_us DESC').count(:heard_about_us)
    render 'show'
  end

  # Chartkick-ready endpoints https://chartkick.com/

  def active_projects_by_status
    results = {}
    Project::STATUSES.each do |k,v|
      next if Project::INACTIVE_STATUSES.include? k
      results[v] = Project.where(status: v).count
    end
    render json: results
  end

  def new_projects_by_month
    render json: Project.where("created_at > ?",
      Time.zone.now - 12.months).group_by_month(:created_at).count
  end

  def new_finishers_by_month
    render json: Finisher.where("created_at > ?",
      Time.zone.now - 12.months).group_by_month(:created_at).count
  end
end
