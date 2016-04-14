import React, { PropTypes } from 'react';
import Dropzone from 'react-dropzone';
import I18n from 'i18n-js';

export const CoverUploader = React.createClass({
    propTypes: {
        cache: PropTypes.string,
        imageUrl: PropTypes.string,
        name: PropTypes.string,
        photoId: PropTypes.number,
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
            removeImage: 0
        };
    },

    onDrop (files) {
        this.setState({
            files,
            hoverClass: '',
            removeImage: 0
        });
    },

    onDragEnter () {
        this.setState({
            hoverClass: 'dropzone--cover--hovering'
        });
    },

    onDragLeave () {
        this.setState({
            hoverClass: ''
        });
    },

    deleteButton () {
        if (this.displayedImage()) {
            return (
                <div className='dropzone--cover-delete-image' onClick={this.removeImage}>
                    <span className='fa fa-close' />
                    <span>{I18n.t('formtastic.labels.remove_image')}</span>
                </div>
            );
        }
    },

    displayedImage () {
        if (this.state.files.length > 0) {
            return this.state.files[0].preview;
        } else if (this.state.removeImage === 0) {
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
            backgroundImage: `url(${this.displayedImage()})`
        };

        return (
            <div >
                <div className={`dropzone--cover--container ${this.state.hoverClass}`}>
                    <Dropzone accept={this.props.supportedFileTypes}
                              className="dropzone--cover"
                              multiple={false}
                              name={`${this.props.name}[image]`}
                              onDragEnter={this.onDragEnter}
                              onDragLeave={this.onDragLeave}
                              onDragOver={this.onDragOver}
                              onDrop={this.onDrop}>
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
                <input name={`${this.props.name}[id]`} type="hidden" value={this.props.photoId}/>
                <input name={`${this.props.name}[image_cache]`} type="hidden" value={this.props.cache}/>
                <input name={`${this.props.name}[used_as]`} type="hidden" value={this.props.type}/>
                <input name={`${this.props.name}[_destroy]`} type="hidden" value={this.state.removeImage}/>
                {this.deleteButton()}
                <noscript>

                    <label>
                        {I18n.t('formtastic.labels.cover_photo_add')}
                        <input name={`${this.props.name}[image]`} type="file" accept={this.props.supportedFileTypes}/>
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
