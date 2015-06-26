"use strict";

class BulkTagAddPane extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      performing: false,
    };
  }

  perform() {
    if ( ! this.state.tag ) return;

    this.setState({performing: true});
    Promise.all(Object.getOwnPropertyNames(this.props.images).map((image_id) => {
      var image = this.props.images[image_id];
      image._links.tags.post({id: this.state.tag.id})
    })).then((values) => {
      console.log(values);
      if (this.props.onComplete) this.props.onComplete();
      this.setState({performing: false});
    });
  }

  onTagChange(tag) {
    this.setState({tag: tag});
  }

  get body() {
    if (this.state.performing) {
      return <span>Performing...</span>;
    } else {
      return <div className="panel-body">
        <TagSelector onChange={this.onTagChange.bind(this)} autoFocus={true} />
        <button className="btn btn-primary" onClick={this.perform.bind(this)} disabled={!this.state.tag}>Add!</button>
      </div>
    }
  }

  render() {
    return (
      <div className="panel panel-default">
        <div className="panel-heading">Bulk add tag for {Object.getOwnPropertyNames(this.props.images).length} images</div>
        {this.body}
      </div>
    );
  }
}
