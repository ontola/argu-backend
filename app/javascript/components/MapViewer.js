import React from 'react'
import LeafletMap from './LeafletMap';

export const MapViewer = React.createClass({
    propTypes: {
        accessToken: React.PropTypes.string,
        centerLat: React.PropTypes.string,
        centerLon: React.PropTypes.string,
        initialZoom: React.PropTypes.number,
        markers: React.PropTypes.array,
        popup: React.PropTypes.object
    },

    getInitialState () {
        return {
            popup: undefined,
            zoom: this.props.initialZoom
        }
    },

    handleMapClick (e) {
        if (this.props.popup) {
            this.setState({ popup: Object.assign({}, this.props.popup, { position: e.latlng, zoom: this.state.zoom }) });
        }
    },

    handleMapZoom (e) {
        this.setState({ zoom: e.target._zoom });
    },

    handlePopupClose () {
        this.setState({ popup: undefined });
    },

    render() {
        return (
            <LeafletMap
                accessToken={this.props.accessToken}
                centerLat={this.props.centerLat}
                centerLon={this.props.centerLon}
                markers={this.props.markers}
                onClick={this.handleMapClick}
                onPopupClose={this.handlePopupClose}
                onZoom={this.handleMapZoom}
                popup={this.state.popup}
                zoom={this.state.zoom}/>
        );
    }
});
export default MapViewer;
