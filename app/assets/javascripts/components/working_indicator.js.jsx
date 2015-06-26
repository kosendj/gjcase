"use strict";

class WorkingIndicator extends React.Component {
  render() {
    if (this.props.run) {
      return (
        <span>^o^</span>
      );
    } else {
      return (
        <span />
      );
    }
  }
}
