import ReactDOM from 'react-dom';

function isTouchDevice() {
    return (('ontouchstart' in window)
    || (navigator.MaxTouchPoints > 0)
    || (navigator.msMaxTouchPoints > 0));
    //navigator.msMaxTouchPoints for microsoft IE backwards compatibility
}

const HyperDropdownMixin = {
    getInitialState: function () {
        this.listeningToClick = true;
        this.openedByClick = false;
        return {
            openState: false,
            opened: false,
            renderLeft: false,
            dropdownElement: {}
        };
    },

    calculateRenderLeft: function () {
        this.referenceDropdownElement().style.left = '0';
        this.referenceDropdownElement().style.right = 'auto';
        var elemRect = this.referenceDropdownElement().getBoundingClientRect();
        var shouldRenderLeft = (elemRect.width + elemRect.left) > window.innerWidth;
        this.setState({renderLeft: shouldRenderLeft});
    },

    close: function () {
        this.listeningToClick = true;
        this.openedByClick = false;
        this.setState({openState: false});
    },

    componentDidMount: function () {
        let domRef = ReactDOM.findDOMNode(this);
        this.setState({
            referenceDropdownElement: domRef.getElementsByClassName('dropdown-content')[0],
            dropdownElement: domRef.getElementsByClassName('dropdown-content')[1]});
        window.addEventListener('resize', this.handleResize);
        this.calculateRenderLeft();
    },

    componentWillUnmount: function () {
        window.removeEventListener('resize', this.handleResize);
        window.clearTimeout(this.mouseEnterOpenedTimeout);
    },

    handleClick: function (e) {
        e.preventDefault();
        e.stopPropagation();
        if (this.listeningToClick) {
            if (this.state.openState) {
                this.close();
            } else {
                this.open();
            }
        } else {
            this.openedByClick = true;
            this.listeningToClick = true;
        }
    },

    handleClickOutside: function () {
        if (this.state.openState === true) {
            this.close();
        }
    },

    mouseEnterTimeoutCallback: function () {
        this.listeningToClick = true;
    },

    onMouseEnter: function () {
        if (!isTouchDevice() && !this.state.openState) {
            this.listeningToClick = false;
            // Start timer to prevent a quick close after clicking on the trigger
            this.mouseEnterOpenedTimeout = window.setTimeout(this.mouseEnterTimeoutCallback, 1000);
            this.open();
        }
    },

    onMouseLeave: function () {
        if (!isTouchDevice() && this.state.openState) {
            if (!this.openedByClick) {
                this.close();
                // Remove / reset timer
                window.clearTimeout(this.mouseEnterOpenedTimeout);
            }
        }
    },

    handleResize: function () {
        this.calculateRenderLeft();
    },

    open: function () {
        this.setState({openState: true, opened: true});
    },

    // Used to calculate the width of a dropdown content menu
    referenceDropdownElement: function () {
        let refDropdown;
        if (typeof this.state.referenceDropdownElement !== 'undefined') {
            refDropdown = this.state.referenceDropdownElement;
        } else {
            refDropdown = ReactDOM.findDOMNode(this).getElementsByClassName('dropdown-content')[0];
        }
        return refDropdown;
    }
};
export default HyperDropdownMixin;
window.HyperDropdownMixin = HyperDropdownMixin;
