class Manage::ReportsController < Manage::ManageController

  # GET /manage/reports
  def index; end

  # Add route for each report and link on dashboard
  # @results is a hash { "Label1" => value1, "Label2" => value2 }
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

    # Ugly, yes, but this preserves the order
    # of the STATUSES.
    #
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

  def project_countries
    counts = Project.group(:country).order('count_id DESC').count(:id)
    respond_to do |format|
      format.csv { render_csv(counts) }
      format.json { render json: counts }
    end
  end

  def finisher_countries
    counts = Finisher.group(:country).order('count_id DESC').count(:id)
    respond_to do |format|
      format.csv { render_csv(counts) }
      format.json { render json: counts }
    end
  end

  def project_counts
    @description = "Counts of Projects by Status"
    @columns = %w(status count)

    @results = {}
    Project::STATUSES.each do |k,v|
      @results[v] = Project.where(status: v).count
    end
    @results["TOTAL -- all statuses"] = Project.count
    @results["NOT DONE -- total less DONE"] = @results["TOTAL -- all statuses"] - Project.where(status: "DONE").count
    render 'show'
  end

  private

  def render_csv(results)
    csv_string = CSV.generate do |csv|
      csv << ['Country', 'Count']
      results.each do |label, value|
        csv << [label, value]
      end
    end

    response.headers["Content-Type"] = "text/csv"
    render plain: csv_string
  end
end
