import _ from 'lodash';
import inflection from 'inflection';

const toPath = name => `${inflection.underscore(name)}/${inflection.underscore(name)}`;
const toComponent = name => require(`components/external/vcwiz/${toPath(name)}`).default;

const ComponentNames = ['Discover', 'Filter', 'Search', 'List', 'Outreach', 'Intro', 'InvestorSettings', 'InvestorSignup'];
const Components = _.fromPairs(_.map(ComponentNames, name => [name, toComponent(name)]));