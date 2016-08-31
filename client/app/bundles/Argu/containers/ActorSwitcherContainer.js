/* globals I18n */
import React, { PropTypes } from 'react';
import { connect } from 'react-redux';
import { actorUpdate } from '../actions';
import ActorItem from '../components/ActorItem';

const NOTHING_OR_USER_ACTOR = 2;

const propTypes = {
  actorUpdate: PropTypes.func,
  close: PropTypes.func,
  managedPages: PropTypes.arrayOf(
    PropTypes.shape({
      title: PropTypes.string,
      image: PropTypes.object,
      update_url: PropTypes.string,
      url: PropTypes.string,
    })
  ).isRequired,
};

const ActorSwitcherContainer = ({ actorUpdate: actorUpdateAction, close, managedPages }) => {
  if (managedPages && managedPages.length < NOTHING_OR_USER_ACTOR) {
    return <div />;
  }

  const items = managedPages.map((item, i) => (
    <ActorItem
      actorUpdate={actorUpdateAction}
      done={close}
      key={i}
      {...item}
    />
  ));

  return (
    <div>
      <span className="dropdown-header">{I18n.t('pages.management.title')}</span>
      {items}
    </div>
  );
};

ActorSwitcherContainer.propTypes = propTypes;

function mapStateToProps(state) {
  return {
    managedPages: state.session.managed_pages,
  };
}

export default connect(
  mapStateToProps,
  { actorUpdate }
)(ActorSwitcherContainer);
