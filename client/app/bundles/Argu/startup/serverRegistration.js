import ReactOnRails from 'react-on-rails';
import Select from 'react-select';

import configureStore from '../stores/configureStore';
import ActiveToggle from '../components/ActiveToggle';
import PageTransferFormApp from '../apps/PageTransferFormApp';
import NavbarApp from '../apps/NavbarApp';
import BigVoteApp from '../apps/BigVoteApp';
import CurrentProfile from '../components/CurrentProfile';
import HyperDropdown from '../components/HyperDropdown';
import ShareDropdown from '../components/ShareDropdown';
import SmallVoteApp from '../apps/SmallVoteApp';
import VotePie from '../components/VotePie';
import VoteStats from '../components/VoteStats';

import { NewMembership } from '../components/NewMembership';
import { MotionSelect } from '../components/_search';

ReactOnRails.registerStore({
  arguStore: configureStore,
});
ReactOnRails.register({
  ActiveToggle,
  BigVoteApp,
  CurrentProfile,
  HyperDropdown,
  MotionSelect,
  NavbarApp,
  NewMembership,
  PageTransferFormApp,
  Select,
  ShareDropdown,
  SmallVoteApp,
  VotePie,
  VoteStats,
});
