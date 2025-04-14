class AddJobLog < ActiveRecord::Migration[8.0]
  def change
    create_table "job_logs" do |t|
      t.text :output
      t.timestamps
    end
  end
end
