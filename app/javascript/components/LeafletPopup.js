import React from 'react'

export const LeafletPopup = React.createClass({
    propTypes: {
        header: React.PropTypes.object,
        onClose: React.PropTypes.func,
        position: React.PropTypes.object,
        zoom: React.PropTypes.number
    },

    componentDidMount () {
        //Only runs on Client, not on server render
        const reactLeaflet = require('react-leaflet');
        this.Popup = reactLeaflet.Popup;
        this.forceUpdate();
    },

    stringWithPlaceholders (str) {
        let string = str.slice();
        if (this.props.position) {
            string = string.replace('{lat}', this.props.position.lat).replace('{lon}', this.props.position.lng);
        }
        if (this.props.zoom) {
            string = string.replace('{zoom}', this.props.zoom);
        }
        return string;
    },

    render() {
        if (this.Popup === undefined) {
            return <div/>;
        }

        let header;
        if (this.props.header) {
            header = (
                <a href={this.stringWithPlaceholders(this.props.header.href)}>
                    <h3 className={this.props.header.class}>
                        {this.props.header.fa ? <span className={`fa fa-${this.props.header.fa}`}/> : null}
                        {this.props.header.text}
                    </h3>
                </a>
            );
        }

        return (
            <this.Popup onClose={this.props.onClose} position={this.props.position}>
                {header}
            </this.Popup>
        );
    }
});
export default LeafletPopup;
