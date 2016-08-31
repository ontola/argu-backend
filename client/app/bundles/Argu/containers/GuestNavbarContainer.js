import { connect } from 'react-redux';
import GuestNavbar from '../components/GuestNavbar';

function mapStateToProps(state) {
  return state.navbarApp;
}

export default connect(mapStateToProps)(GuestNavbar);
