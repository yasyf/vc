class Team < ApplicationRecord
  include Concerns::Slackable

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
    config['listserv']
  end

  def slack_channel
    config['channel']
  end

  def notify!(message, all: true)
    return if config['ignore']
    slack_send! slack_channel, message, notify: all
  end

  private

  def config
    @config ||= Rails.configuration.teams[name]
  end
end
