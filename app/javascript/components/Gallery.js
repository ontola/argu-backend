import React from 'react';
import Lightbox from 'react-images';

export const Gallery = React.createClass({
    propTypes: {
        files: React.PropTypes.array
    },

    getInitialState () {
        return {
            currentImage: 0,
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

    images () {
        return this.props.files.filter(file => { return (file.is_image); });
    },

    imageIndex (index) {
        return this.props.files.slice(0, index).filter(file => { return (file.is_image); }).length;
    },

    renderGallery () {
        const { files } = this.props;

        if (!files || files.length === 0) {
            return <div />;
        }

        const gallery = files.map((obj, i) => {
            return obj.is_image ? this.renderImage(obj, i) : this.renderFile(obj, i);
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
        return (
            <div>
                {this.renderGallery()}
                <Lightbox
                    currentImage={this.state.currentImage}
                    images={this.images()}
                    isOpen={this.state.lightboxIsOpen}
                    onClickImage={this.handleClickImage}
                    onClickNext={this.handleClickNext}
                    onClickPrev={this.handleClickPrev}
                    onClickThumbnail={this.handleClickThumbnail}
                    onClose={this.handleOnClose}/>
            </div>
        );
    }
});

export default Gallery;
