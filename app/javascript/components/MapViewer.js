import React from 'react'
import LeafletMap from './LeafletMap';

export const MapViewer = React.createClass({
    propTypes: {
        accessToken: React.PropTypes.string,
        centerLat: React.PropTypes.string,
        centerLon: React.PropTypes.string,
        initialZoom: React.PropTypes.number,
        markers: React.PropTypes.array
    },

    getInitialState () {
        return {
            zoom: this.props.initialZoom
        }
    },

    handleMapZoom (e) {
        this.setState({ zoom: e.target._zoom });
    },

    render() {
        return (
            <LeafletMap
                accessToken={this.props.accessToken}
                centerLat={this.props.centerLat}
                centerLon={this.props.centerLon}
                markers={this.props.markers}
                onZoom={this.handleMapZoom}
                zoom={this.state.zoom}/>
        );
    }
});
export default MapViewer;
