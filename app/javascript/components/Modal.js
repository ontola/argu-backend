import React from 'react'

export const Modal = React.createClass({
    propTypes: {
        children: React.PropTypes.array,
        onClose: React.PropTypes.func
    },

    getInitialState () {
        return {
            hide: false
        }
    },

    componentWillMount() {
        document.addEventListener('keyup', this.handleKeyUp.bind(this));
    },

    componentWillUnmount() {
        document.removeEventListener('keyup', this.handleKeyUp.bind(this));
    },

    closeModal () {
        this.setState({ hide: true });
        window.setTimeout(() => {
            this.props.onClose();
        }, 500);
    },

    handleCloseModal (e) {
        e.preventDefault();
        this.closeModal();
    },

    handleKeyUp (e) {
        if (e.key === 'Escape'){
            this.closeModal();
        }
    },

    render() {
        return (
            <div className={`react-modal-container ${this.state.hide ? 'modal-hide' : ''}`}>
                <div className="overlay" onClick={this.handleCloseModal}/>
                <div className="modal col-1">
                    <div className="box">
                        {this.props.children}
                    </div>
                </div>
            </div>
        );
    }
});
export default Modal;
