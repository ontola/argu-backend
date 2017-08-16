import React from 'react'
import { LeafletPopup } from './LeafletPopup';

export const LeafletMap = React.createClass({
    propTypes: {
        accessToken: React.PropTypes.string,
        centerLat: React.PropTypes.string,
        centerLon: React.PropTypes.string,
        markers: React.PropTypes.array,
        onClick: React.PropTypes.func,
        onPopupClose: React.PropTypes.func,
        onZoom: React.PropTypes.func,
        popup: React.PropTypes.object,
        zoom: React.PropTypes.number
    },

    componentDidMount () {
        //Only runs on Client, not on server render
        const reactLeaflet = require('react-leaflet');
        const leaflet = require('leaflet');
        this.Map = reactLeaflet.Map;
        this.TileLayer = reactLeaflet.TileLayer;
        this.Marker = reactLeaflet.Marker;
        this.Icon = leaflet.Icon;
        this.forceUpdate();
    },

    render () {
        if (this.Map === undefined) {
            return <div className="leaflet-placeholder"/>;
        }
        const markers = this.props.markers.map((marker, index) => {
            let markerPopup;
            if (marker.popup) {
                markerPopup = <LeafletPopup {...marker.popup}/>;
            }
            return (
                <this.Marker key={`marker-${index}`} icon={new this.Icon(marker.icon)} position={[marker.lat, marker.lon]}>
                    {markerPopup}
                </this.Marker>
            );
        });
        let popup;
        if (this.props.popup) {
            popup = <LeafletPopup onClose={this.props.onPopupClose} {...this.props.popup}/>;
        }
        return (
            <this.Map center={[this.props.centerLat, this.props.centerLon]} onZoom={this.props.onZoom} onClick={this.props.onClick} zoom={this.props.zoom}>
                <this.TileLayer
                    accessToken={this.props.accessToken}
                    attribution="&copy; <a href='http://openstreetmap.org'>OpenStreetMap</a> &copy; <a href='http://mapbox.com'>Mapbox</a>"
                    id="mapbox.streets"
                    url="https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token={accessToken}"/>
                {markers}
                {popup}
            </this.Map>
        );
    }
});
export default LeafletMap;
