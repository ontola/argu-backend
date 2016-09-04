import { connect } from 'react-redux';
import GuestNavbar from '../components/GuestNavbar';

function mapStateToProps(state) {
  const ca = state.getIn(['current-actors', 'items', 'currentactor']);
  return {
    forumSelector: ca.get('forumSelector')
  };
}

export default connect(mapStateToProps)(GuestNavbar);
