"use strict";

class Paginator extends React.Component {
  goPrev() {
    this.props.onPaginate(false);
  }

  goNext() {
    this.props.onPaginate(true);
  }

  render() {
    return (
      <div className="paginator">
        <button className="btn btn-default" onClick={this.props.doLucky}>lucky</button>
        <button className="btn btn-default" onClick={this.goPrev.bind(this)}>prev</button>
        {this.props.page}/{this.props.maxPage}
        <button className="btn btn-default" onClick={this.goNext.bind(this)}>next</button>
      </div>
    );
  }
}
