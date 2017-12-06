class TargetInvestorImportRowJob < ApplicationJob
  queue_as :now

  def perform(import_task_id, raw)
    ImportTask.find(import_task_id).import_row!(raw)
  end
end
