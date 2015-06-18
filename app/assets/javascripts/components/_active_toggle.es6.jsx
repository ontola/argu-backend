var ActiveToggle = React.createClass({
    getInitialState: function() {
        "use strict";
        return {
            toggleState: this.props.initialState,
            loading: false
        };
    },

    handleClick: function (picture) {
        "use strict";
        var self = this,
            newState = !this.state.toggleState;
        this.setState({loading: true});
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
                self.setState({loading: false});
            }
        });
    },

    render: function () {
        var currentProps = this.props[`${this.state.toggleState}_props`];
        if (this.props.label !== false) {
            var label = <span className='icon-left'>{currentProps.label}</span>;
        }

        return (
            <div onClick={this.handleClick} className={this.state.loading ? 'is-loading' : ''}>
                <span className={`fa fa-${currentProps.icon}`}></span>
                {label}
            </div>
        )
    }
});

if (typeof module !== 'undefined' && module.exports) {
    module.exports = ActiveToggle;
}
