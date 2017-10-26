import I18n from 'i18n-js';
import React from 'react'

import HoverBox from './HoverBox';

const MAX_ARGUMENTS_SHOWN = 3;
const TRUNCATE_LENGTH = 250;

export const ArgumentsList = React.createClass({
    propTypes: {
        arguments: React.PropTypes.arrayOf(React.PropTypes.shape({
            body: React.PropTypes.string,
            commentCount: React.PropTypes.number,
            id: React.PropTypes.number,
            displayName: React.PropTypes.string,
            side: React.PropTypes.string,
            url: React.PropTypes.string
        })),
        onOpenArgumentForm: React.PropTypes.func.isRequired,
        onShowAllArguments: React.PropTypes.func.isRequired,
        showAllArguments: React.PropTypes.bool.isRequired
    },

    getInitialState () {
        return {
        }
    },

    sideList (side) {
        const list = this.props.arguments.filter(el => {
            return el.side === side;
        });

        return list;
    },

    slicedSideList (side) {
        let list = this.sideList(side);
        if (this.props.showAllArguments === false) {
            list = list.slice(0, MAX_ARGUMENTS_SHOWN);
        }
        return list.map(argument => {
            return this.argument(argument, side);
        });
    },

    addArgumentButton (side) {
        return (
          <li className="box-list-item--subtle">
            <a href="#" data-value={side} onClick={this.props.onOpenArgumentForm}>{I18n.t(`arguments.new.${side}`)}</a>
          </li>
        )
    },

    argumentTitle (item, side) {
      return (
        <a
          data-remote='true'
          href={item.url} >
          <h4 className={`${side}-t tooltip--wider`}>
            <div className="list-item">
              <span>{item.displayName}</span>
              {item.commentCount > 0 &&
                <div className="comments-counter comments-counter--inline">
                  <div className="fa fa-comment"/>
                  <div className="icon-left">{item.commentCount}</div>
                </div>
              }
            </div>
          </h4>
        </a>
      )
    },

    truncate (string) {
        if (string.length > TRUNCATE_LENGTH) {
            return string.substring(0, TRUNCATE_LENGTH) + '...';
        }
        return string;
    },

    argument (item, side) {
        if (item.body === null) {
            return this.argumentTitle(item, side)
        }
        return (
          <HoverBox children={
              this.argumentTitle(item, side)
            }
            hiddenChildren={
              <p style={{ marginBottom: 0 }}>{this.truncate(item.body)}</p>
          }/>
        )
    },

    showMoreButton (side, count) {
        return (
          <li className="box-list-item--subtle">
            <a
              data-value={side}
              href="#"
              onClick={this.props.onShowAllArguments}>
              {I18n.t(`arguments.show_all_x_${side}`, { count })}
            </a>
          </li>
        )
    },

    renderButton (side, count) {
        if (count > MAX_ARGUMENTS_SHOWN && this.props.showAllArguments === false) {
            return (
              this.showMoreButton(side, count)
            );
        }
        return (
          this.addArgumentButton(side)
        );
    },

    render() {
        return (
            <section className="section--bottom">
              <ul className="box-list box-list--arguments">
                {this.slicedSideList('pro')}
                {this.renderButton('pro', this.sideList('pro').length)}
              </ul>
              <ul className="box-list box-list--arguments">
                {this.slicedSideList('con')}
                {this.renderButton('con', this.sideList('con').length)}
              </ul>
            </section>
        );
    }
});
export default ArgumentsList;
