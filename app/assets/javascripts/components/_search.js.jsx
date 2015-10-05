/*global $*/
import React from 'react/react-with-addons';

window.MotionOption = React.createClass({
    propTypes: {
        addLabelText: React.PropTypes.string,
        className: React.PropTypes.string,
        mouseDown: React.PropTypes.func,
        mouseEnter: React.PropTypes.func,
        mouseLeave: React.PropTypes.func,
        option: React.PropTypes.object.isRequired,
        renderFunc: React.PropTypes.func
    },

    render () {
        const obj = this.props.option;
        return (
            <div className={this.props.className}
                 onMouseEnter={this.props.mouseEnter}
                 onMouseLeave={this.props.mouseLeave}
                 onMouseDown={this.props.mouseDown}
                 onClick={this.props.mouseDown}>
                <img class="Select-item-result-icon" height='25em' src={obj.image} />
                {obj.label}
            </div>
        );
    }
});

window.MotionSelect = React.createClass({
    getInitialState () {
        this.currentFetchTimer = 0;
        return {
            display_name: this.props.display_name,
            image: this.props.image
        };
    },

    loadOptions (input, callback) {
        input = input.toLowerCase();
        if (!input.length) {
            return callback({
                options: [],
                complete: true
            });
        }

        window.clearTimeout(this.currentFetchTimeout);
        this.currentFetchTimeout = window.setTimeout(() => {
            let params = {
                q: input,
                thing: 'motion'
            };
            fetch(`/${this.props.forum}/m.json?${$.param(params)}`, safeCredentials())
                .then(statusSuccess)
                .then(json)
                .then((data) => {
                    callback(null, {
                        options: data.map((motion) => {
                            return {
                                id: motion.id.toString(),
                                value: motion.id.toString(),
                                name: motion.display_name,
                                label: motion.display_name,
                                image: motion.cover_photo.avatar.url
                            };
                        }),
                        complete: false
                    });
                }).catch((e) => {
                    Argu.Alert('Server error occured, please try again later', 'alert', true);
                    console.log('callback');
                    callback(null, {options: [], complete: false});
                });
        }, 500);
    },

    filterOptions: function (results, filter, currentValues) {
        return results || currentValues;
    },

    render () {

        return (<Select
            name="question_answer[motion_id]"
            placeholder="Select motion"
            matchProp="any"
            ignoreCase="true"
            filterOptions={this.filterOptions}
            optionComponent={MotionOption}
            singleValueComponent={SingleValue}
            asyncOptions={this.loadOptions}  />);
    }
});
