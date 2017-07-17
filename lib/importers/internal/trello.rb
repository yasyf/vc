module Importers::Internal
  class Trello
    SEPARATOR = ' - '
    IGNORES = %w(INSTRUCTIONS)

    def initialize(team)
      @team = team
    end

    def sync!(deep: false)
      @team.trello_board_ids.each do |trello_board_id|
        board = ::Trello::Board.find(trello_board_id, { fields: 'dateLastActivity' })
        next unless @team.updated_at < board.last_activity_date || (deep && @team.companies.pitched.undecided.present?)
        @team.touch
        board.cards.each do |card|
          next if IGNORES.include?(card.name)
          parsed = parse(card)
          yield parsed if parsed.present?
        end
        board.cards(filter: :closed).each do |card|
          yield ({ trello_id: card.id, closed: card.closed })
        end
      end
    rescue ::Trello::Error => e
      Rails.logger.error e
    end

    private

    class DateTimeNotFound < StandardError
      def log!(card, team)
        users = card.members.map { |mem| User.from_trello(mem.id) }.compact
        users = team unless users.present?
        LoggedEvent.log! :datetime_not_found, card, card.list.name, card.name, card.url,
          to: users, data: { name: card.name }
      end
    end

    def parse(card)
      parsed = {
        trello_id: card.id,
        name: clean_name(card.name),
        trello_list_id: card.list_id,
        members: card.members,
        closed: card.closed,
      }
      begin
        parsed.merge! parse_pitch_on(card) if card.list_id == @team.lists.scheduled.trello_id
      rescue DateTimeNotFound => dtnf
        dtnf.log! card, @team
        return nil
      end
      parsed
    rescue ::Trello::Error => e
      Rails.logger.warn e
      nil
    end

    def parse_pitch_on(card)
      return { pitch_on: card.due } if card.due.present?
      name, datestring = split_name card
      index = datestring.index /\d/
      raise DateTimeNotFound, name unless index.present?
      date = Chronic.parse(datestring[index..-1], context: :past)
      raise DateTimeNotFound, name unless date.present?
      { pitch_on: date, name: clean_name(name) }
    end

    def clean_name(name)
      name.split(/\s[\(\[\-]/).first.strip
    end

    def split_name(card)
      raise DateTimeNotFound, card.name unless card.name.include?(SEPARATOR)
      *nameparts, datestring = card.name.split(SEPARATOR)
      [nameparts.join(SEPARATOR), datestring]
    end
  end
end
