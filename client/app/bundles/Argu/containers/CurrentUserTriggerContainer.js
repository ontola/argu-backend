import { connect } from 'react-redux';
import CurrentUserTrigger from '../components/CurrentUserTrigger';

function mapStateToProps(state) {
  const { activeId } = state.session;
  const {
    title,
    image: profilePhoto,
  } = state
        .session
        .managed_pages
        .find(page => page.id === activeId);

  return {
    title,
    profilePhoto,
  };
}

export default connect(mapStateToProps)(CurrentUserTrigger);
