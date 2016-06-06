def select_bombed(items)
  items.select do |item|
    item.reactions.present? && item.reactions.map(&:name).include?("bomb")
  end
end

namespace :scripts do
  namespace :slack do
    desc "TODO"
    task :detonate_bombs, [:channel] => [:environment] do |t, args|
      client = Slack::Web::Client.new

      history = client.channels_history channel: args[:channel], count: 1000
      bombed = select_bombed history.messages
      responses = Workers.map(bombed) do |message|
        client.chat_delete ts: message.ts, channel: args[:channel], as_user: true
      end
      deleted = responses.select { |m| m.ok }
      puts "#{bombed.count} messages found, #{deleted.count} messages deleted!"

      file_list = client.files_list channel: args[:channel], count: 1000
      bombed = select_bombed file_list.files
      responses = Workers.map(bombed) do |file|
        client.files_delete file: file.id
      end
      deleted = responses.select { |m| m.ok }
      puts "#{bombed.count} files found, #{deleted.count} files deleted!"
    end
  end
end
