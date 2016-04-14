import React, { PropTypes } from 'react';
let RichTextEditor;
if (process.env.CLIENT_SIDE === true) {
    RichTextEditor = require('react-rte').default;
}

export const TextEditor = React.createClass({
    propTypes: {
        name: PropTypes.string.isRequired,
        placeholder: PropTypes.string,
        rows: PropTypes.number,
        value: PropTypes.string.isRequired
    },

    getDefaultProps() {
        return {
            placeholder: 'Type here...',
            rows: 4
        };
    },

    getInitialState () {
        document.getElementsByName(this.props.name)[0].remove();
        const value = this.props.value === '' ?
            RichTextEditor.createEmptyValue() :
            RichTextEditor.createValueFromString(this.props.value, 'markdown');
        return {
            value
        };
    },

    onChange (value) {
        this.setState({ value });
    },

    textareaStyle: {
        width: '100%'
    },

    render () {
        return (
            <div>
                <RichTextEditor
                    onChange={this.onChange}
                    placeholder={this.props.placeholder}
                    style={this.state.textEditorStyle}
                    value={this.state.value} />
                <input name={this.props.name} style={{ display: 'none' }} type="hidden" value={this.state.value.toString('markdown')} />
            </div>
        );
    }
});
window.TextEditor = TextEditor;
