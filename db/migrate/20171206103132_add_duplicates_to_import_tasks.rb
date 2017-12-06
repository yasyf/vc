class AddDuplicatesToImportTasks < ActiveRecord::Migration[5.1]
  def change
    remove_column :import_tasks, :errored
    add_column :import_tasks, :errored, :integer, array: true, default: []
    add_column :import_tasks, :duplicates, :jsonb, array: true, default: []
  end
end
