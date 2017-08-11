import React from 'react'
import LeafletMap from './LeafletMap';
import I18n from 'i18n-js';

export const MapPicker = React.createClass({
    propTypes: {
        accessToken: React.PropTypes.string,
        centerLat: React.PropTypes.string,
        centerLon: React.PropTypes.string,
        icon: React.PropTypes.object,
        initialZoom: React.PropTypes.number,
        markerId: React.PropTypes.number,
        markerLat: React.PropTypes.string,
        markerLon: React.PropTypes.string,
        markerType: React.PropTypes.string,
        required: React.PropTypes.bool,
        resourceType: React.PropTypes.string
    },

    getInitialState () {
        return {
            center: {
                lat: this.props.markerLat || this.props.centerLat,
                lng: this.props.markerLon || this.props.centerLon
            },
            hasLocation: !!(this.props.required || (this.props.markerLat && this.props.markerLon)),
            marker: {
                lat: this.props.markerLat,
                lng: this.props.markerLon
            },
            zoom: this.props.initialZoom
        };
    },

    handleAddLocation () {
        this.setState({ hasLocation: true });
    },

    handleMapClick (e) {
        this.setState({ marker: e.latlng });
    },

    handleRemoveLocation () {
        this.setState({ hasLocation: false, marker: { lat: undefined, lng: undefined } });
    },

    handleMapZoom (e) {
        this.setState({ zoom: e.target._zoom });
    },

    render() {
        if (this.state.hasLocation === false) {
            let destroyFields;
            if (this.props.markerId) {
                destroyFields = <div>
                    <input type="hidden" name={`${this.props.resourceType}[edge_attributes][placements_attributes][0][id]`} value={this.props.markerId}/>
                    <input type="hidden" name={`${this.props.resourceType}[edge_attributes][placements_attributes][0][_destroy]`} value={true}/>
                </div>;
            }
            return (
                <div>
                    <a className="btn-subtle" onClick={this.handleAddLocation}>
                        <span className="fa fa-plus"/>
                        <span className="icon-left">{I18n.t('formtastic.map.add_marker')}</span>
                    </a>
                    {destroyFields}
                </div>
            );
        }
        let removeLink;
        if (!this.props.required) {
            removeLink = <div>
                <a className="btn-subtle" onClick={this.handleRemoveLocation}>
                    <span className="fa fa-minus"/>
                    <span className="icon-left">{I18n.t('formtastic.map.remove_marker')}</span>
                </a>
            </div>;
        } else if (!this.state.marker.lat && !this.state.marker.lng) {
            removeLink = <div className="warning-box">{I18n.t('formtastic.map.required')}</div>;
        }
        const markers = this.state.marker.lat ? [{ lat: this.state.marker.lat, lon: this.state.marker.lng, icon: this.props.icon }] : [];
        return (
            <div>
                <LeafletMap
                    accessToken={this.props.accessToken}
                    centerLat={this.state.center.lat}
                    centerLon={this.state.center.lng}
                    markers={markers}
                    onClick={this.handleMapClick}
                    onZoom={this.handleMapZoom}
                    zoom={this.state.zoom}/>
                {removeLink}
                <input type="hidden" name={`${this.props.resourceType}[edge_attributes][placements_attributes][0][id]`} value={this.props.markerId}/>
                <input type="hidden" name={`${this.props.resourceType}[edge_attributes][placements_attributes][0][placement_type]`} value={this.props.markerType}/>
                <input type="hidden" name={`${this.props.resourceType}[edge_attributes][placements_attributes][0][lat]`} value={this.state.marker.lat}/>
                <input type="hidden" name={`${this.props.resourceType}[edge_attributes][placements_attributes][0][lon]`} value={this.state.marker.lng}/>
                <input type="hidden" name={`${this.props.resourceType}[edge_attributes][placements_attributes][0][zoom_level]`} value={this.state.zoom}/>
            </div>
        );
    }
});
export default MapPicker;
