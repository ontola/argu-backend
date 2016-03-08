import React from 'react';
import { statusSuccess, json } from '../lib/helpers';

export const PostalCodeButton = React.createClass({
    getInitialState: function () {
        return {
            state: 0
        };
    },

    handleClick: function (e) {
        e.preventDefault();
        this.setState({state: 1});
        var form_field_id = this.props.form_field_id;
        var that = this;
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(function(position) {
                fetch("https://nominatim.openstreetmap.org/search/" + position.coords.latitude + "," + position.coords.longitude + "?format=json&addressdetails=1&limit=1")
                    .then(statusSuccess)
                    .then(json)
                    .then((data) => {
                        document.getElementById(form_field_id).value = data[0].address.postcode;
                        that.setState({state: -1});
                });
            });
        }
    },

    render: function() {
        switch (this.state.state) {
            case 0:
                return (<a href="/" onClick={this.handleClick}>{this.props.button_text}</a>);
                break;
            case 1:
                return (<span>{this.props.searching_text}</span>);
                break;
            case -1:
                return (<span></span>);
            break;
        }
    }
});

window.PostalCodeButton = PostalCodeButton;

