import React from 'react';
import WrappedTable from '../global/shared/wrapped_table';
import EmojiModal from './emoji_modal';
import PartnerModal from './partner_modal';
import FixedTable from '../global/shared/fixed_table';
import {initials, ffetch, isMobile} from '../global/utils';
import {TargetInvestorsPath, TargetInvestorStagesKeys} from '../global/constants.js.erb';
import Actions from '../global/actions';
import Store from '../global/store';
import IntroModal from './intro_modal';
import NoteModal from './note_modal';

class ConversationsTable extends FixedTable {
  onTrackChange = (row, update) => {
    const id = this.props.array.getSync(row, false).id;
    ffetch(TargetInvestorsPath.id(id), 'PATCH', {target_investor: update}).then(() => {
      this.props.onRowUpdate(row, update, true);
      Actions.trigger('refreshFounder');
    });
  };

  renderColumns() {
    const { dimensions } = this.props;

    const partner = this.renderPartnerColumn('full_name', 'Partner', { imageKey: 'investor.photo', verifiedKey: 'investor.verified', subKey: 'title' }, 2);
    const emoji = this.renderEmojiColumn('priority', 'Tag');


    if (isMobile()) {
      return [partner, emoji];
    }

    return [
      partner,
      this.renderTrackColumn('stage', this.onTrackChange, 'Stage'),
      this.renderIntroColumn('intro_requests[0]', 'VCWiz Intro', { eligibleKey: 'can_intro?', emailKey: 'email_present?', stageKey: 'stage' }),
      emoji,
      this.renderTruncatedTextColumn('note', 'Notes', {lines: 2}, 2),
      this.renderDatetimeColumn('last_response', 'Last Response'),
    ];
  }
}

export default class Conversations extends React.Component {
  render() {
    let { targets, ...rest } = this.props;
    return (
      <WrappedTable
        items={targets}
        modal={(key, item) => {
          const { target_investors } = Store.get('founder', {});
          const target = _.find(target_investors, {id: item.id});
          switch (key) {
            case 'full_name':
              if (item.investor_id)
                return PartnerModal;
              break;
            case 'priority':
              return EmojiModal;
            case 'note':
              return NoteModal;
            case 'intro_requests[0]':
              if (item['can_intro?'] && target.stage === _.first(TargetInvestorStagesKeys))
                return IntroModal;
              break;
          }
        }}
        isFaded={row => _.includes(_.takeRight(TargetInvestorStagesKeys, 3), row.stage)}
        table={ConversationsTable}
        {...rest}
      />
    );
  }
}