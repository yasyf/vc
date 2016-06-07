def select_reactioned(items, reaction)
  items.select do |item|
    item.reactions.present? && item.reactions.map(&:name).include?(reaction)
  end
end

namespace :scripts do
  namespace :slack do
    desc "Detonate All The Bombs"
    task :detonate_bombs, [:channel] => [:environment] do |t, args|
      client = Slack::Web::Client.new

      history = client.channels_history channel: args[:channel], count: 1000
      bombed = select_reactioned history.messages, "bomb"
      responses = Workers.map(bombed) do |message|
        client.chat_delete ts: message.ts, channel: args[:channel], as_user: true
      end
      deleted = responses.select { |m| m.ok }
      puts "#{bombed.count} messages found, #{deleted.count} messages deleted!"

      file_list = client.files_list channel: args[:channel], count: 1000
      bombed = select_reactioned file_list.files, "bomb"
      responses = Workers.map(bombed) do |file|
        client.files_delete file: file.id
      end
      deleted = responses.select { |m| m.ok }
      puts "#{bombed.count} files found, #{deleted.count} files deleted!"
    end

    desc "Collect Evergreen Advice"
    task :collect_evergreens, [:channel] => [:environment] do |t, args|
      client = Slack::Web::Client.new
      history = client.channels_history channel: args[:channel], count: 1000
      evergreen = select_reactioned history.messages, "evergreen_tree"
      evergreen.each do |message|
        Knowledge.where(ts: message.ts).first_or_create! do |knowledge|
          knowledge.body = message.text
          knowledge.user = User.from_slack(message.user)
        end
      end
      puts "#{evergreen.count} imported!"
    end
  end
end
