import { connect } from 'react-redux';
import { indexNotifications } from '../actions';
import NotificationsList from '../components/NotificationsList';

const mapStateToProps = state => state.notifications;

export default connect(
  mapStateToProps,
  { indexNotifications }
)(NotificationsList);
