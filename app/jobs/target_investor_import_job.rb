class TargetInvestorImportJob < ApplicationJob
  queue_as :now

  def perform(import_task_id)
    ImportTask.find(import_task_id).import!
  end
end
