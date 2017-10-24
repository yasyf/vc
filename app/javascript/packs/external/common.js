import _ from 'lodash';

const toPath = (name) => `${name.toLowerCase()}/${name.toLowerCase()}`;
const toComponent = (name) => require(`components/external/vcwiz/${toPath(name)}`).default;

const ComponentNames = ['Discover', 'Filter', 'List', 'Outreach'];
const Components = _.fromPairs(_.map(ComponentNames, name => [name, toComponent(name)]));