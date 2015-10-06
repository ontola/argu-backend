
window.BannerFormContainer = React.createClass({
    getInitialState: function () {
        return {};
    },

    render: function () {


        return (
            <div>
                <BannerForm />
                <Banner />
            </div>
        );
    }
});

if (typeof module !== 'undefined' && module.exports) {
    module.exports = BannerFormContainer;
}
