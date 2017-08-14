import React from 'react'
import MapViewer from './MapViewer';
import Modal from './Modal';

export const MapToggle = React.createClass({
    propTypes: {
        accessToken: React.PropTypes.string,
        centerLat: React.PropTypes.string,
        centerLon: React.PropTypes.string,
        initialZoom: React.PropTypes.number,
        markers: React.PropTypes.array,
        tooltip: React.PropTypes.string
    },

    getInitialState () {
        return {
            modal: false
        }
    },

    handleClick (e) {
        e.preventDefault();
        this.setState({ modal: true });
    },

    handleModalClose () {
        this.setState({ modal: false });
    },

    render() {
        let modal;
        if (this.state.modal) {
            modal = <Modal onClose={this.handleModalClose}><MapViewer {...this.props}/></Modal>
        }
        return (
            <div className="detail">
                <div className="detail__icon">
                    <a href="">
                        <span className="fa fa-map-marker" onClick={this.handleClick}/>
                    </a>
                </div>
                {modal}
            </div>
        );
    }
});
export default MapToggle;
