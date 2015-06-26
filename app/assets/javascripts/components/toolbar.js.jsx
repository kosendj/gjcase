"use strict";

class Toolbar extends React.Component {
  render() {
    return (
      <div className="toolbar">
        <button className="btn btn-default" onClick={(() => this.props.onButton('bulk_tag_add')).bind(this)}>+Tags</button>
        <button className="btn btn-default" onClick={(() => this.props.onButton('send_gj')).bind(this)}>Send to GJ</button>
        <TagSelector placeholder="Find by tag" onChange={this.props.onTagChange} disableCreate={true} />
      </div>
    );
  }
}
