import React from 'react';
import I18n from 'i18n-js';
import Collection from '../Collection';
import Token from './Token';

export const TokenList = React.createClass({
    propTypes: {
        columns: React.PropTypes.array,
        header: React.PropTypes.string,
        iri: React.PropTypes.string,
        onPageLoaded: React.PropTypes.func,
        retractHandler: React.PropTypes.func,
        shouldLoadPage: React.PropTypes.bool
    },

    renderer (values) {
        const { columns, retractHandler } = this.props;
        if (values === undefined) {
            return <p>{I18n.t('tokens.loading')}</p>;
        } else if (values.length === 0) {
            return <div/>;
        }
        const headCols = columns.map(column => {
            return <td key={column}>{I18n.t(`tokens.labels.${column}`)}</td>;
        });
        const rows = values.map(token => {
            return <Token columns={columns} key={token.id} retractHandler={retractHandler} token={token}/>;
        });
        const header = (this.props.header === undefined) ? <div/> : <legend><span>{this.props.header}</span></legend>;
        return (
            <div>
                {header}
                <table>
                    <thead className="subtle">
                    <tr>
                        {headCols}
                        <td></td>
                    </tr>
                    </thead>
                    <tbody>
                        {rows}
                    </tbody>
                </table>
            </div>
        );
    },

    render () {
        return <Collection iri={this.props.iri} onPageLoaded={this.props.onPageLoaded} renderer={this.renderer} shouldLoadPage={this.props.shouldLoadPage}/>;
    }
});

export default TokenList;
