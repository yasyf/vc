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
      lists = DEFAULT['lists'].map do |name|
        List.where(trello_board_id: trello_board_id, name: config['lists'][name]).first!
      end
      Lists.new *lists
    end
  end

  def trello_board_id
    config['board']
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

  def notify!(message, all: true)
    return if config['ignore']
    slack_send! slack_channel, message, notify: all
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
