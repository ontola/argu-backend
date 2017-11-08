import Pagination from 'react-js-pagination';
import React from 'react';
import { safeCredentials, statusSuccess, json } from './lib/helpers';
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
        this.fetchPage(`${this.props.iri}?page=${pageNumber}`);
    },

    fetchPage (iri) {
        this.setState({ loading: true });
        fetch(iri, safeCredentials())
            .then(statusSuccess)
            .then(json)
            .then(data => {
                let members = data.data.relationships.members.data;
                if (!members || members.length === 0) {
                    this.setState({ itemsCountPerPage: data.data.attributes.pageSize, totalItemsCount: data.data.attributes.totalCount });
                    members = this.includedResources(data, data.data.relationships.views.data.map(obj => { return obj.id; }))[0].relationships.members.data;
                }
                if (members && members.length > 0) {
                    this.props.onPageLoaded(members);
                    this.setState({ loading: false, values: this.includedResources(data, members.map(obj => { return obj.id; })) });
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
