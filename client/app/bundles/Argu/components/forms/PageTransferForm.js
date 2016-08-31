import React, { Component, PropTypes } from 'react';
import { reduxForm } from 'redux-form';

import {
    Form,
    ProfileSelectInput,
    StringInput,
} from './components';

const propTypes = {
  authenticityToken: PropTypes.string,
  fields: PropTypes.object,
  organisation: PropTypes.string,
};

class PageTransferFormComponent extends Component {
  actionUrl() {
    return `/o/${this.props.organisation}/transfer`;
  }

  render() {
    const { authenticityToken, fields: { repeatName, profileId } } = this.props;

    return (
      <Form
        action={this.actionUrl()}
        authenticityToken={authenticityToken}
        className="page"
        method="put"
      >
        <StringInput
          label="Herhaal Argu URL"
          {...repeatName}
          id="page_repeat_name"
          name="page[repeat_name]"
        />
        <ProfileSelectInput
          label="Kies gebruiker"
          {...profileId}
          id="profile_id"
          name="profile_id"
        />
        <button type="submit">
          I understand the consequences, transfer ownership of this organization.
        </button>
      </Form>
    );
  }
}

PageTransferFormComponent.propTypes = propTypes;

const PageTransferForm = reduxForm({
  fields: ['repeatName', 'profileId'],
  form: 'pageTransfer',
})(PageTransferFormComponent);

export default PageTransferForm;
