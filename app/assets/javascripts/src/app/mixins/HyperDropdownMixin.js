import ReactDOM from 'react-dom';

const CLICK_AND_HOLD_TIMEOUT = 1000;

function isTouchDevice() {
    return (('ontouchstart' in window)
    || (navigator.MaxTouchPoints > 0)
    || (navigator.msMaxTouchPoints > 0));
    //navigator.msMaxTouchPoints for microsoft IE backwards compatibility
}

const HyperDropdownMixin = {
    getInitialState () {
        this.listeningToClick = true;
        this.openedByClick = false;
        return {
            openState: false,
            opened: false,
            renderLeft: false,
            dropdownElement: {}
        };
    },

    calculateRenderLeft () {
        this.referenceDropdownElement().style.left = '0';
        this.referenceDropdownElement().style.right = 'auto';
        const elemRect = this.referenceDropdownElement().getBoundingClientRect();
        const shouldRenderLeft = (elemRect.width + elemRect.left) > window.innerWidth;
        this.setState({ renderLeft: shouldRenderLeft });
    },

    close () {
        this.listeningToClick = true;
        this.openedByClick = false;
        this.setState({ openState: false });
    },

    componentDidMount () {
        const domRef = ReactDOM.findDOMNode(this);
        /* eslint-disable */
        this.setState({
            referenceDropdownElement: domRef.getElementsByClassName('dropdown-content')[0],
            dropdownElement: domRef.getElementsByClassName('dropdown-content')[1]
        });
        /* eslint-enable*/
        window.addEventListener('resize', this.handleResize);
        this.calculateRenderLeft();
    },

    componentWillUnmount () {
        window.removeEventListener('resize', this.handleResize);
        window.clearTimeout(this.mouseEnterOpenedTimeout);
    },

    handleClick (e) {
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

    handleClickOutside () {
        if (this.state.openState === true) {
            this.close();
        }
    },

    mouseEnterTimeoutCallback () {
        this.listeningToClick = true;
    },

    onMouseEnter () {
        if (!isTouchDevice() && !this.state.openState) {
            this.listeningToClick = false;
            // Start timer to prevent a quick close after clicking on the trigger
            this.mouseEnterOpenedTimeout = window.setTimeout(this.mouseEnterTimeoutCallback, CLICK_AND_HOLD_TIMEOUT);
            this.open();
        }
    },

    onMouseLeave () {
        if (!isTouchDevice() && this.state.openState) {
            if (!this.openedByClick) {
                this.close();
                // Remove / reset timer
                window.clearTimeout(this.mouseEnterOpenedTimeout);
            }
        }
    },

    handleResize () {
        this.calculateRenderLeft();
    },

    open () {
        this.setState({ openState: true, opened: true });
    },

    // Used to calculate the width of a dropdown content menu
    referenceDropdownElement () {
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
