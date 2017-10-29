import React from 'react';
import WrappedTable from '../global/shared/wrapped_table';
import EmojiModal from './emoji_modal';
import PartnerModal from './partner_modal';
import FixedTable from '../global/shared/fixed_table';
import {initials} from '../global/utils';
import {TargetInvestorsPath} from '../global/constants.js.erb';

class ConversationsTable extends FixedTable {
  renderColumns() {
    return [
      this.renderImageTextColumn('name', 'Partner', { imageKey: 'investor.photo', fallbackFn: initials, subKey: 'title', max: 18 }, 2),
      this.renderTrackColumn('stage', 'Stage'),
      this.renderIntroColumn('intro_request', 'VCWiz Intro', { eligibleKey: 'can_intro?' }),
      this.renderEmojiColumn('priority', <div className="emoji-heading">!!!</div>),
      this.renderTextColumn('note', 'Notes', 2),
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
        modal={{
          name: PartnerModal,
          priority: EmojiModal,
        }}
        table={ConversationsTable}
        source={{path: TargetInvestorsPath, query: {}}}
        {...rest}
      />
    );
  }
}