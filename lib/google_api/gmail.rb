require 'google/apis/gmail_v1'

module GoogleApi
  class Gmail < Base
    SCOPES = [Google::Apis::GmailV1::AUTH_GMAIL_READONLY]

    def initialize(user)
      @user = user
      @gmail = Google::Apis::GmailV1::GmailService.new
      @gmail.authorization = authorization
      @gmail.quota_user = @user.id.to_s
      @gmail.user_ip = @user.ip_address.to_s
      @pool = Workers::Pool.new(logger: Rails.logger, on_exception: proc { |e| Raven.capture_exception(e) }, size: 3)
    end

    def sync!
      if @user.history_id.present?
        sync_partial!
      else
        sync_full!
      end
    ensure
      @pool.dispose(30)
    end

    private

    def sync_partial!
      begin
        response = list_histories
      rescue Google::Apis::ClientError
        sync_full!
        return
      end

      return unless response.history.present?
      loop do
        message_ids = response.history.flat_map do |history|
          history.messages_added.reject { |ma| ma.message.label_ids&.include?('DRAFT') }.map { |ma| ma.message.id }
        end.uniq
        get_messages(message_ids) do |message|
          process_message message
        end if message_ids.present?
        @user.update! history_id: response.history_id
        unless response.next_page_token.present?
          break
        end
        response = list_histories response.next_page_token
      end
    end

    def sync_full!
      response = list_threads
      history_id = response.threads.first.history_id
      loop do
        thread_ids = response.threads.map(&:id)
        get_threads(thread_ids)  do |thread|
          process_thread thread
        end if thread_ids.present?
        break unless response.next_page_token.present?
        response = list_threads response.next_page_token
      end
      @user.update! history_id: history_id
    end

    def process_thread(thread)
      thread.messages.last(2).each do |message|
        process_message(message)
      end
    end

    def process_message(message)
      return unless message.present?
      @pool.perform do
        ActiveRecord::Base.connection_pool.with_connection do
          Message.new(message).process!(@user)
        end
      end
    end

    %w(thread message).each do |s|
      define_method("get_#{s}s") do |ids, &block|
        @gmail.batch do |batch|
          ids.each do |id|
            batch.public_send("get_user_#{s}", @user.email, id) do |res, err|
              if err.present?
                if err.is_a? Google::Apis::ClientError
                  Rails.logger.warn err
                else
                  raise err
                end
              else
                block.call(res)
              end
            end
          end
        end
      end
    end

    def list_histories(token = nil)
      @gmail.list_user_histories(@user.email, history_types: 'messageAdded', start_history_id: @user.history_id, page_token: token)
    end

    def list_threads(token = nil, limit = '6m')
      @gmail.list_user_threads(@user.email, page_token: token, q: "newer_than:#{limit}")
    end
  end
end