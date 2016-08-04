class List < ActiveRecord::Base
  has_many :companies

  validates :trello_id, presence: true, uniqueness:true
  validates :name, presence: true
  validates :pos, presence: true, uniqueness: true

  %w(application allocated scheduled pitched funded passed ice_box).each do |list_type|
    define_singleton_method(list_type) do
      if (result = instance_variable_get("@#{list_type}")).nil?
        result = where(name: ENV["TRELLO_#{list_type.upcase}_LIST"]).first!
        instance_variable_set "@#{list_type}", result
      end
      result
    end
  end

  def self.funnel
    where('pos > ?', ice_box.pos).where('pos < ?', scheduled.pos).or(where('id = ?', allocated.id))
  end

  def self.sync!
    Trello::Board.find(ENV['TRELLO_BOARD']).lists.each do |list_data|
      list = List.where(trello_id: list_data.id).first_or_create
      list.assign_attributes %w(name pos).map { |p| [p, list_data.public_send(p)] }.to_h
      list.save! if list.changed?
    end
  end
end
