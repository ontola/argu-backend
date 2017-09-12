import React from 'react';
import Lightbox from 'react-images';
import VideoViewer from './VideoViewer';
import Modal from './Modal';

export const Gallery = React.createClass({
    propTypes: {
        files: React.PropTypes.array
    },

    getInitialState () {
        return {
            currentImage: 0,
            currentVideo: null,
            lightboxIsOpen: false
        };
    },

    openLightbox (index, event) {
        event.preventDefault();
        this.setState({
            currentImage: index,
            lightboxIsOpen: true
        });
    },

    handleOnClose () {
        this.setState({
            currentImage: 0,
            lightboxIsOpen: false
        });
    },

    handleClickPrev () {
        this.setState({
            currentImage: this.state.currentImage - 1
        });
    },

    handleClickNext () {
        this.setState({
            currentImage: this.state.currentImage + 1
        });
    },

    handleClickThumbnail (index) {
        this.setState({
            currentImage: index
        });
    },

    handleClickImage () {
        if (this.state.currentImage === this.images().length - 1) {
            return;
        }

        this.handleClickNext();
    },

    handleVideoClose () {
        this.setState({ currentVideo: null })
    },

    images () {
        return this.props.files.filter(file => { return (file.type === 'image'); });
    },

    imageIndex (index) {
        return this.props.files.slice(0, index).filter(file => { return (file.type === 'image'); }).length;
    },

    openVideo (e) {
        this.setState({ currentVideo: this.props.files[e.target.dataset.number] })
    },

    renderGallery () {
        const { files } = this.props;

        if (!files || files.length === 0) {
            return <div />;
        }

        const gallery = files.map((obj, i) => {
            switch (obj.type) {
            case 'image':
                return this.renderImage(obj, i);
            case 'video':
                return this.renderVideo(obj, i);
            default:
                return this.renderFile(obj, i);
            }
        });

        return (
            <div className="gallery">
                {gallery}
            </div>
        );
    },

    renderFile (obj, i) {
        return (
            <a data-title={obj.caption}
               href={obj.src}
               key={i}
               target='_blank'>
                <span className={`fa fa-${obj.thumbnail}`} />
            </a>
        );
    },

    renderVideo (obj, i) {
        return (
            <a data-title={obj.caption}
               key={i}
               onClick={this.openVideo}>
                <img src={obj.thumbnail} />
                <span className="fa fa-play" data-number={i}/>
            </a>
        );
    },

    renderImage (obj, i) {
        const clickHandler = e => { this.openLightbox(this.imageIndex(i), e) };
        return (
            <a data-title={obj.caption}
               href={obj.src}
               key={i}
               onClick={clickHandler} >
               <img src={obj.thumbnail} />
            </a>
        );
    },

    render() {
        let videoModal;
        if (this.state.currentVideo) {
            videoModal = <Modal onClose={this.handleVideoClose}><VideoViewer {...this.state.currentVideo}/></Modal>
        }
        return (
            <div>
                {this.renderGallery()}
                <Lightbox
                    backdropClosesModal={true}
                    currentImage={this.state.currentImage}
                    images={this.images()}
                    isOpen={this.state.lightboxIsOpen}
                    onClickImage={this.handleClickImage}
                    onClickNext={this.handleClickNext}
                    onClickPrev={this.handleClickPrev}
                    onClickThumbnail={this.handleClickThumbnail}
                    onClose={this.handleOnClose}/>
                {videoModal}
            </div>
        );
    }
});

export default Gallery;
