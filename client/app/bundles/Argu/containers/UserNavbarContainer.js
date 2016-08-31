import { connect } from 'react-redux';
import UserNavbar from '../components/UserNavbar';

function mapStateToProps(state) {
  return state.navbarApp;
}

export default connect(mapStateToProps)(UserNavbar);
