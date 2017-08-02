import React from 'react';
import I18n from 'i18n-js';
import Token from './Token';

export const TokenList = props => {
    const { columns, retractHandler, tokens } = props;
    if (tokens === undefined) {
        return <p>{I18n.t('tokens.loading')}</p>;
    } else if (tokens.length === 0) {
        return <div/>;
    }
    const headCols = columns.map(column => {
        return <td key={column}>{I18n.t(`tokens.labels.${column}`)}</td>;
    });
    const rows = tokens.map(token => {
        return <Token columns={columns} key={token.id} retractHandler={retractHandler} token={token}/>;
    });
    const header = (props.header === undefined) ? <div/> : <legend><span>{props.header}</span></legend>;
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
};

const TokenListProps = {
    columns: React.PropTypes.array,
    header: React.PropTypes.string,
    retractHandler: React.PropTypes.func,
    tokens: React.PropTypes.array
};
TokenList.propTypes = TokenListProps;

export default TokenList;
