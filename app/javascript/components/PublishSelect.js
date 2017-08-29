import React from 'react';
import Select from 'react-select';
import Datetime from 'react-datetime';
import I18n from 'i18n-js';

export const PublishSelect = React.createClass({
    propTypes: {
        publicationId: React.PropTypes.integer,
        publishAt: React.PropTypes.string,
        publishType: React.PropTypes.string,
        publishTypes: React.PropTypes.array,
        resourceType: React.PropTypes.string
    },

    getInitialState () {
        return {
            publishAt: this.props.publishAt,
            publishType: this.props.publishType,
            selectDateTime: false
        };
    },

    handleChange (value) {
        if (value.value === 'schedule') {
            this.setState({ publishType: value.value, selectDateTime: true })
        } else {
            this.setState({ publishType: value.value, selectDateTime: false })
        }
    },

    handleCloseDateTime () {
        this.setState({ selectDateTime: false })
    },

    handleDateTimeChange (e) {
        this.setState({ publishAt: e._d });
    },

    isValidDate (currentDate) {
        return currentDate.isAfter(Datetime.moment().subtract(1, 'day'));
    },

    valueRenderer (obj) {
        if (this.state.publishType === 'schedule' && this.state.publishAt) {
            return (
                <span className="Select-value-label Select-value-label-datetime" role="option">
                    <span className="datetime-label">{obj.label}</span>
                    <span className="datetime-value">{`: ${Datetime.moment(this.state.publishAt).format('D MMM, H:mm')}`}</span>
                </span>
            );
        } else {
            return <span className="Select-value-label" role="option">{obj.label}</span>
        }
    },

    render () {
        let dateTime, publishedAtField;
        if (this.state.selectDateTime) {
            dateTime = <div className="rdtWrapper">
                <Datetime
                    defaultValue={Datetime.moment(this.state.publishAt)}
                    input={false}
                    isValidDate={this.isValidDate}
                    locale={I18n.locale}
                    onChange={this.handleDateTimeChange}
                    open={true}/>
                <div className="btn btn-datetime" onClick={this.handleCloseDateTime}>
                    {I18n.t('formtastic.actions.create')}
                </div>
            </div>
        }
        if (this.state.publishType === 'schedule') {
            publishedAtField = <input type="hidden"
                                      name={`${this.props.resourceType}[edge_attributes][argu_publication_attributes][published_at]`}
                                      value={this.state.publishAt}/>;
        }
        return (
            <div>
                {dateTime}
                {publishedAtField}
                <input type="hidden" name={`${this.props.resourceType}[edge_attributes][argu_publication_attributes][id]`} value={this.props.publicationId}/>
                <input type="hidden" name={`${this.props.resourceType}[edge_attributes][argu_publication_attributes][draft]`} value={this.state.publishType === 'draft'}/>
                <Select
                    className="schedule-select"
                    clearable={false}
                    onChange={this.handleChange}
                    options={this.props.publishTypes}
                    value={this.state.publishType}
                    valueRenderer={this.valueRenderer}/>
            </div>
        );
    }
});

export default PublishSelect;
