import React, { PropTypes } from 'react';
import Dropzone from 'react-dropzone';
import I18n from 'i18n-js';
import Slider from 'react-rangeslider'

export const CoverUploader = React.createClass({
    propTypes: {
        cache: PropTypes.string,
        imageUrl: PropTypes.string,
        name: PropTypes.string,
        photoId: PropTypes.number,
        positionY: PropTypes.number,
        supportedFileTypes: PropTypes.string,
        type: PropTypes.string
    },

    getDefaultProps() {
        return {
            supportedFileTypes: 'image/jpg,image/jpeg,image/png,image/webp'
        };
    },

    getInitialState () {
        return {
            files: [],
            hoverClass: '',
            removeImage: 0,
            positionY: this.props.positionY
        };
    },

    handleDrop (files) {
        this.setState({
            files,
            hoverClass: '',
            removeImage: 0
        });
    },

    handleDragEnter () {
        this.setState({
            hoverClass: 'dropzone--cover--hovering'
        });
    },

    handleDragLeave () {
        this.setState({
            hoverClass: ''
        });
    },

    handleLog (value) {
        this.setState({
            positionY: value
        });
    },

    deleteButton () {
        if (this.displayedImage()) {
            return (
                <div
                  className='dropzone--cover-delete-image'
                  onClick={this.removeImage}>
                    <span className='fa fa-close' />
                    <span>{I18n.t('formtastic.labels.remove_image')}</span>
                </div>
            );
        }
        return null;
    },

    displayedImage () {
        if (this.state.files.length > 0) {
            return this.state.files[0].preview;
        } else if (this.state.removeImage === 0 && this.props.imageUrl !== null) {
            return this.props.imageUrl;
        } else {
            return '';
        }
    },

    removeImage () {
        this.setState({
            files: [],
            removeImage: 1
        });
    },

    render () {
        const imageStyle = {
            backgroundImage: `url(${this.displayedImage()})`,
            backgroundPositionY: `${this.state.positionY}%`
        };

        return (
            <div >
                <div className={`dropzone--cover--container ${this.state.hoverClass}`}>
                    <Dropzone accept={this.props.supportedFileTypes}
                              className="dropzone--cover"
                              multiple={false}
                              name={`${this.props.name}[image]`}
                              onDragEnter={this.handleDragEnter}
                              onDragLeave={this.handleDragLeave}
                              onDragOver={this.handleDragOver}
                              onDrop={this.handleDrop}>
                        <div className="dropzone--cover-borders">
                            <div className="box-image--container">
                                <div className="box-image" style={imageStyle}></div>
                            </div>
                            <div className="dropzone--cover-insides flex-center">
                                <div className="fa fa-camera" />
                                <div className="dropzone--cover-text">{I18n.t('formtastic.labels.cover_photo_add')}</div>
                            </div>
                        </div>
                    </Dropzone>
                </div>
                {(this.displayedImage()) &&
                  <Slider
                    onChange={this.handleLog}
                    orientation={'vertical'}
                    reverse={true}
                    tooltip={false}
                    value={this.state.positionY} />
                }
                <input name={`${this.props.name}[id]`} type="hidden" value={this.props.photoId}/>
                <input name={`${this.props.name}[image_cache]`} type="hidden" value={this.props.cache}/>
                <input name={`${this.props.name}[used_as]`} type="hidden" value={this.props.type}/>
                <input name={`${this.props.name}[_destroy]`} type="hidden" value={this.state.removeImage}/>
                <input name={`${this.props.name}[content_attributes][position_y]`} type="hidden" value={this.state.positionY}/>
                {this.deleteButton()}
                <noscript>
                    <label>
                        {I18n.t('formtastic.labels.cover_photo_add')}
                        <input
                          accept={this.props.supportedFileTypes}
                          name={`${this.props.name}[image]`}
                          type="file" />
                    </label>
                    <label>
                        {I18n.t('formtastic.labels.remove_image')}
                        <input name={`${this.props.name}[_destroy]`} type="checkbox"/>
                    </label>
                </noscript>
            </div>
        )
    }
});

window.CoverUploader = CoverUploader;
