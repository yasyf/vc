class Card < ApplicationRecord
  belongs_to :list
  belongs_to :company
  has_one :pitch
  has_one :team, through: :company

  validates :company, presence: true
  validates :list, presence: true
  validates :trello_id, presence: true, uniqueness: true

  def trello_url
    "https://trello.com/c/#{trello_id}"
  end

  def move_to_list!(list)
    update! list: list

    trello_card.move_to_list list.trello_id
    trello_card.save
  rescue Trello::Error
  end

  def move_to_rejected_list!
    list = pitch.pitched? ? team.lists.passed : team.lists.rejected
    move_to_list! list
  rescue Trello::Error
  end

  def move_to_post_pitch_list!
    list = pitch.funded? ? team.lists.pre_funded : team.lists.passed
    move_to_list! list

    trello_card.name = company.name
    trello_card.save
  rescue Trello::Error
  end

  def add_user(user)
    trello_card.add_member user.trello_user
    trello_card.save
  rescue Trello::Error
  end

  def add_comment!(comment)
    trello_card.add_comment "**[DRFBot]** #{comment}"
  rescue Trello::Error
    false
  end

  def members
    @members ||= trello_card.members
  end

  private

  def trello_card
    @trello_card ||= Trello::Card.find trello_id
  end
end
