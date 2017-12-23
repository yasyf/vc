import React from 'react';
import WrappedTable from '../global/shared/wrapped_table';
import EmojiModal from './emoji_modal';
import PartnerModal from './partner_modal';
import FixedTable from '../global/shared/fixed_table';
import {initials, ffetch} from '../global/utils';
import {TargetInvestorsPath, TargetInvestorStagesKeys} from '../global/constants.js.erb';
import Actions from '../global/actions';
import Store from '../global/store';
import IntroModal from './intro_modal';

class ConversationsTable extends FixedTable {
  onTrackChange = (row, update) => {
    const id = this.props.array.getSync(row, false).id;
    ffetch(TargetInvestorsPath.id(id), 'PATCH', {target_investor: update}).then(() => {
      Actions.trigger('refreshFounder');
    });
  };

  renderColumns() {
    return [
      this.renderImageTextColumn('full_name', 'Partner', { imageKey: 'investor.photo', fallbackFn: initials, verifiedKey: 'investor.verified', subKey: 'title', max: 18 }, 2),
      this.renderTrackColumn('stage', this.onTrackChange, 'Stage'),
      this.renderIntroColumn('intro_requests[0]', 'VCWiz Intro', { eligibleKey: 'can_intro?', emailKey: 'email_present?', stageKey: 'stage' }),
      this.renderEmojiColumn('priority', 'Tag'),
      this.renderPlaceholderColumn('note', 'Notes', 2),
      this.renderDatetimeColumn('last_response', 'Last Response'),
    ]
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
              break;
            case 'intro_requests[0]':
              if (item['can_intro?'] && target.stage === _.first(TargetInvestorStagesKeys))
                return IntroModal;
              break;
          }
        }}
        isFaded={row => row.stage === _.last(TargetInvestorStagesKeys)}
        table={ConversationsTable}
        {...rest}
      />
    );
  }
}