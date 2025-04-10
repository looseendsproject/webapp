# frozen_string_literal: true

# == Schema Information
#
# Table name: job_logs
#
#  id         :bigint           not null, primary key
#  output     :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class JobLog < ApplicationRecord
end
