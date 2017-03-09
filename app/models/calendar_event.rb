class CalendarEvent < ApplicationRecord
  belongs_to :user
  belongs_to :company

  def add_notes!(notes)
    google_drive.append notes_doc.id, 'text/html',
      "<h3>#{user.name}</h3><h4>#{DateTime.now.to_s(:long)}</h4><div>#{notes.gsub("\n", '<br>')}</div>"
  end

  def notes_doc
    self.update! notes_doc_link: find_or_create_notes_doc!.web_view_link if notes_doc_link.blank?
    find_or_create_notes_doc!
  end

  private

  def google_drive
    @google_drive ||= GoogleApi::Drive.new(user)
  end

  def find_or_create_notes_doc!
    file_name = "#{company.name} Coffee Chat"
    google_drive.find(file_name, in_folders: user.team.coffee_chats_folder_id, cache: false) || google_drive.create(
      file_name,
      'application/vnd.google-apps.document',
      StringIO.new("<div><h1>#{company.name} Coffee Chats</h1></div>"),
      user.team.coffee_chats_folder_id,
      'text/html',
    )
  end
end
