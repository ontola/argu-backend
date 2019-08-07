import Pagination from 'react-js-pagination';
import React from 'react';
import { safeCredentialsJsonApi, statusSuccess, json } from './lib/helpers';
import 'whatwg-fetch';

export const Collection = React.createClass({
    propTypes: {
        iri: React.PropTypes.string,
        onPageLoaded: React.PropTypes.func,
        renderer: React.PropTypes.func
    },

    getInitialState () {
        return {
            itemsCountPerPage: 0,
            loading: true,
            page: 1,
            totalItemsCount: 0,
            values: []
        };
    },

    componentWillReceiveProps (nextProps) {
        if (nextProps.shouldLoadPage) {
            this.setState({ page: 1 });
            this.fetchPage(this.props.iri);
        }
    },

    handlePageChange (pageNumber) {
        this.setState({ page: pageNumber });
        this.fetchPage(`${this.props.iri}?type=paginated&page=${pageNumber}`);
    },

    fetchPage (iri) {
        this.setState({ loading: true });
        fetch(iri, safeCredentialsJsonApi())
            .then(statusSuccess)
            .then(json)
            .then(data => {
                let memberSequence = data.data.relationships.memberSequence;
                if (!memberSequence) {
                    const defaultView = this.includedResources(data, [data.data.relationships.defaultView.data.id])[0];
                    this.setState({ itemsCountPerPage: defaultView.attributes.count, totalItemsCount: data.data.attributes.totalCount });
                    memberSequence = defaultView.relationships.memberSequence;
                }
                const members = memberSequence && this.includedResources(data, [memberSequence.data.id])[0].relationships.members;
                if (members && members.data.length > 0) {
                    this.props.onPageLoaded(members.data);
                    this.setState({ loading: false, values: this.includedResources(data, members.data.map(obj => { return obj.id; })) });
                }
            });
    },

    includedResources (data, ids) {
        return data.included.filter(obj => {
            return ids.includes(obj.id);
        });
    },

    render () {
        let pagination;
        if (this.state.totalItemsCount > this.state.itemsCountPerPage) {
            pagination = <Pagination
                activePage={this.state.page}
                innerClass="react-pagination"
                itemsCountPerPage={this.state.itemsCountPerPage}
                totalItemsCount={this.state.totalItemsCount}
                pageRangeDisplayed={5}
                onChange={this.handlePageChange}/>;
        }
        return <div className={`collection ${this.state.loading ? 'collection-loading' : ''}`}>
            {this.props.renderer(this.state.values)}
            {pagination}
        </div>;
    }
});

export default Collection;
