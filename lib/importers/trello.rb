module Importers
  class Trello
    SEPARATOR = '-'

    def sync!
      ::Trello::Board.find(ENV['TRELLO_BOARD']).cards.each do |card|
        yield parse(card)
      end
    end

    private

    class DateTimeNotFound < StandardError
      def log!(card)
        usernames = card.members.map { |mem| mem.email.split('@').first }
        LoggedEvent.log! :datetime_not_found, card, card.list.name, card.name, card.url,
          to: usernames, data: { name: card.name }
      end
    end

    def parse(card)
      parsed = {
        trello_id: card.id,
        name: card.name,
        trello_list_id: card.list_id,
        members: card.members
      }
      begin
        parsed.merge! parse_pitch_on(card) if card.list_id == List.pitched.trello_id
      rescue DateTimeNotFound => dtnf
        dtnf.log! card
      end
      parsed
    end

    def parse_pitch_on(card)
      name, datestring = split_name card
      index = datestring.index /\d/
      raise DateTimeNotFound, name unless index.present?
      date = Chronic.parse(datestring[index..-1], context: :past)
      raise DateTimeNotFound, name unless date.present?
      { pitch_on: date, name: name }
    end

    def split_name(card)
      raise DateTimeNotFound, card.name unless card.name.include?(SEPARATOR)
      *nameparts, datestring = card.name.split(SEPARATOR)
      name = nameparts.join(SEPARATOR).split(/[\(\[]/).first.strip
      [name, datestring]
    end
  end
end
