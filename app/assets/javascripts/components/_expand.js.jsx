import React from 'react/react-with-addons';

var Expander = React.createClass({
    getInitialState: function () {
        return {
            openState: false
        };
    },

    toggleOpenState: function () {
        document.getElementById(this.props.expanderTarget).setAttribute('opened', !this.state.openState ? 'opened' : 'closed');
        document.getElementById(this.props.expanderTarget).style.display = !this.state.openState ? 'block' : 'none';
        this.setState({openState: !this.state.openState});
    },

    handleClick: function (e) {
        e.preventDefault();
        this.toggleOpenState();
    },

    url: function () {
        if (this.props.url) {
            return '#' + this.props.url;
        } else {
            return '';
        }
    },

    render: function () {
        var label = typeof(this.props.label) == "object" ?
                (this.state.openState ? this.props.label.opened : this.props.label.closed)
                : this.props.label;
        var showCaret;
        if (this.props.showCaret) {
            showCaret = (<span className={"fa fa-angle-" + (this.state.openState ? 'up' : 'down')}></span>);
        }

        return (
            <a href={this.url()} className={"expander "+this.props.className || ''} onClickCapture={this.handleClick} data-skip-pjax>
                {label}
                {showCaret}
            </a>
        );
    }
});
