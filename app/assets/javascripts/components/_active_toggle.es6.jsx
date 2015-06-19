var ActiveToggle = React.createClass({
    getDefaultProps: function() {
        "use strict";
        return {
            tagName: 'div'
        };
    },

    getInitialState: function() {
        "use strict";
        return {
            toggleState: this.props.initialState
        };
    },

    handleClick: function (picture) {
        "use strict";
        var self = this,
            newState = !this.state.toggleState;
        $.ajax({
            method: this.props[`${newState}_props`].method || 'PATCH',
            url: decodeURI(this.props.url).replace(/{{value}}/, newState.toString()),
            async: true,
            dataType: 'json',
            complete: function (xhr, status) {
                let statusCode = xhr.statusCode().status;
                if (statusCode == 201 || statusCode == 304) {
                    self.setState({toggleState: true});
                } else if (statusCode == 204) {
                    self.setState({toggleState: false});
                } else {
                    console.log('An error occurred');
                }
            }
        });
    },

    render: function () {
        if (this.props.label !== false) {
            var label = <label>{this.props.label}</label>;
        }

        return (
            <this.props.tagName onClick={this.handleClick}>
                {label}
                <span className={`fa fa-${this.props[`${this.state.toggleState}_props`].icon}`}></span>
            </this.props.tagName>
        )
    }
});

if (typeof module !== 'undefined' && module.exports) {
    module.exports = ActiveToggle;
}
