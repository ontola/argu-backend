import React from 'react';
import { statusSuccess, json } from '../lib/helpers';

export const PostalCodeButton = React.createClass({
    handleClick: function (e) {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(function(position) {
                fetch("https://nominatim.openstreetmap.org/search/" + position.coords.latitude + "," + position.coords.longitude + "?format=json&addressdetails=1&limit=1")
                    .then(statusSuccess)
                    .then(json)
                    .then((data) => {
                        document.getElementById('profile_postal_code').value = data[0].address.postcode;
                    }).catch(() => {
                        Alert(this.getIntlMessage('errors.general'), 'alert', true);
                    });
            });
        }
        e.preventDefault();
    },

    render: function() {
        return (<a href="/" onClick={this.handleClick}><span className="fa fa-crosshairs"></span></a>);
    }
});

window.PostalCodeButton = PostalCodeButton;

