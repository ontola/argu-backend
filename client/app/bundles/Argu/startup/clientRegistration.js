import ReactOnRails from 'react-on-rails';
import Select from 'react-select';

import configureStore from 'state';
import ActiveToggle from '../components/ActiveToggle';
import BigVoteApp from '../apps/BigVoteApp';
import PageTransferFormApp from '../apps/PageTransferFormApp';
import NavbarApp from '../apps/NavbarApp';
import HyperDropdown from '../components/HyperDropdown';
import ShareDropdown from '../components/ShareDropdown';
import SmallVoteApp from '../apps/SmallVoteApp';
import CurrentProfile from '../components/CurrentProfile';
import VotePie from '../components/VotePie';
import VoteStats from '../components/VoteStats';

import MotionsApp from '../apps/MotionsApp';

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
  MotionsApp,
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
