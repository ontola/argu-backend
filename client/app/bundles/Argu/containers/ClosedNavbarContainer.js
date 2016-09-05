import { connect } from 'react-redux';
import ClosedNavbar from '../components/ClosedNavbar';

function mapStateToProps(state) {
  const ca = state.getIn(['current-actors', 'items', 'currentactor']);
  return {
    forumSelector: ca.get('forumSelector')
  };
}

export default connect(mapStateToProps)(ClosedNavbar);
