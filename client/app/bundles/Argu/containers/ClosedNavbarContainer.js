import { connect } from 'react-redux';
import ClosedNavbar from '../components/ClosedNavbar';

function mapStateToProps(state) {
  return state.navbarApp;
}

export default connect(mapStateToProps)(ClosedNavbar);
