class ForwardsMailbox < ApplicationMailbox
  before_processing :find_project

  def process
    # TODO
  end

  private

  def find_original_sender
    # find original from in forwarded body
    # find user
  end

  def find_project
    # user/finisher/project
  end

  def record_forward
    # create ProjectNote record
  end
end
