class Team < ApplicationRecord
  include Concerns::Slackable
  include Concerns::Cacheable
  include ActionView::Helpers::NumberHelper

  has_many :companies
  has_many :users

  validates :name, presence: true, uniqueness: true

  DEFAULT = Rails.configuration.teams['default']
  ALL = Rails.configuration.teams.reject { |_, c| c['ignore'] }.keys
  Lists = Struct.new('Lists', *DEFAULT['lists'])

  Rails.configuration.teams.keys.each do |name|
    define_singleton_method(name) do
      if (result = instance_variable_get("@#{name}")).nil?
        result = where(name: name).first!
        instance_variable_set "@#{name}", result
      end
      result
    end
  end

  def self.for_each
    ALL.each { |name| yield send(name) }
  end

  def self.default
    where(name: DEFAULT['name']).first_or_create!
  end

  def lists
    @lists ||= begin
      all_lists = List.where(trello_board_id: trello_board_ids).map { |l| [l.name, l] }.to_h
      lists = DEFAULT['lists'].map { |name| all_lists[config['lists'][name]] }
      Lists.new *lists
    end
  end

  def funded_lists
    @funded_lists ||= List.where(trello_board_id: trello_board_ids, name: config['lists']['funded'])
  end

  def time_zone
    config['time_zone']
  end

  def full_name
    config['full_name']
  end

  def time_now
    Time.current.in_time_zone(time_zone)
  end

  def datetime_now
    DateTime.current.in_time_zone(time_zone).to_datetime
  end

  def trello_board_ids
    config['boards']
  end

  def email_list
    "#{config['listserv']}@#{ENV['DOMAIN']}"
  end

  def slack_channel
    "##{config['channel']}"
  end

  def snapshot_folder_ids
    config['snapshots']
  end

  def exclude_folder_ids
    config['excludes'] || []
  end

  def prevote_discussions_folder_id
    config['prevote_discussions']
  end

  def coffee_chats_folder_id
    config['coffee_chats']
  end

  def voting_period
    config['voting_period'].days
  end

  def notify!(message, all: true)
    return if config['ignore']
    slack_send! slack_channel, message, notify: all
  end

  def portfolio_top_performers(n = 5)
    companies.order(capital_raised: :desc).select(&:funded?).first(n)
  end

  def anti_portfolio_top_performers(n = 5)
    companies.order(capital_raised: :desc).select(&:passed?).first(n)
  end

  def portfolio_follow_on
    number_to_human(companies.select(&:funded?).sum(&:capital_raised), locale: :money)
  end

  def anti_portfolio_follow_on
    number_to_human(companies.select(&:passed?).sum(&:capital_raised), locale: :money)
  end

  private

  def config
    @config ||= Rails.configuration.teams[name]
  end
end
