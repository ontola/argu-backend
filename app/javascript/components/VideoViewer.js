import React from 'react'

export const VideoViewer = React.createClass({
    propTypes: {
        embed_url: React.PropTypes.string
    },

    render() {
        return (
            <iframe allowFullScreen="allowfullscreen" frameBorder="0" src={this.props.embed_url} width="100%" height="400px"/>
        );
    }
});
export default VideoViewer;
