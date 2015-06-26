"use strict";

class TagSelector extends React.Component {
  constructor(props) {
    super(props);

    this.candidateRefreshTimeout = null;

    this.state = {
      candidates: [],
      form_focused: false,
      form_disabled: false,
      candidates_hovered: false,
      focused_index: null,
      selected_candidate: null,
    };
  }

  notifyChange(val) {
    if (this.props.onChange)
      this.props.onChange(val);
  }

  // ------------

  get newTagsAllowed() {
    return !this.props.disableCreate;
  }

  get mainClassName() {
    var classes = ['tag-selector'];

    if (this.state.confirmed_value) {
      classes << 'tag-selector-state-confirmed';
    }

    if (this.state.form_disabled && !this.state.confirmed_value) {
      classes << 'tag-selector-state-creating';
    }

    return classes.join(' ');
  }

  get showCandidates() {
    return !this.state.form_disabled && !this.state.confirmed_value && this.state.form_has_value && (this.state.form_focused || this.state.candidates_hovered);
  }

  get candidateElems() {
    var selectedCandidate = this.state.selected_candidate;

    var elems = this.state.candidates.map((tag, i) => {

      var className = "tag-selector-candidate";
      if (selectedCandidate && selectedCandidate.id == tag.id)
        className += " tag-selector-candidate-selected";

      return (
        <div className={className} key={tag.id} onMouseOver={this.onCandidateMouseOver.bind(this, i)} onClick={this.onCandidateClick.bind(this, -1)}>
          {tag.name}
        </div>
      );
    });

    if (this.newTagsAllowed) {
      var className = "tag-selector-candidate";
      if (this.state.focused_index == -1) className += " tag-selector-candidate-selected";
      elems.push(
        <div className={className} key="new" onMouseOver={this.onCandidateMouseOver.bind(this, -1)} onClick={this.onCandidateClick.bind(this, -1)}>
          <span style={{color: "gray"}}>+ Create new</span>
        </div>
      );
    }

    return elems
  }

  refreshCandidates(input) {
    var prefix = input.value;
    this.setState({form_has_value: prefix != ""});

    if ( this.state.candidates_prefix == prefix || prefix == "" ) return;

    console.log(`refreshing candidates for prefix: ${input.value}`);
    GjcaseTag.index({prefix: input.value}).then((res) => {
      this.setState({candidates: res.data, candidates_prefix: prefix, focused_index: null});
    });
  }

  // -----------------------------------------------

  confirmCandidate() {
    if ( this.candidateRefreshTimeout ) {
      clearTimeout(this.candidateRefreshTimeout);
      this.candidateRefreshTimeout = null;
    }

    this.finalizeValue(this.state.selected_candidate);
  }

  finalizeValue(tag) {
    if (tag) {
      this.setState({
        form_disabled: false,
        form_value: tag.name,
        confirmed_value: tag,
        candidates: [],
        focused_index: null,
        selected_candidate: null,
      });

      this.notifyChange(tag);
    } else {
      if (! this.newTagsAllowed) {
        console.log('WUT?! no new tags are allowed but unpersisted finalize request came..')
        return;
      }

      this.setState({
        form_disabled: true,
        candidates: [],
        focused_index: null,
        selected_candidate: null,
      });

      GjcaseTag.post(null, {name: this.state.form_value}).then((res) => this.finalizeValue(res.data));
    }
  }

  onCandidateMouseOver(i) {
    if ( i == -1 ) {
      this.setState({focused_index: -1, selected_candidate: null});
    } else {
      this.setState({focused_index: i, selected_candidate: this.state.candidates[i]});
    }
  }

  onCandidateClick(i) {
    this.onCandidateMouseOver(i);
    this.confirmCandidate();
  }

  // -----------------------------------------------

  keyFocusPrev(ev) {
    var focused_index = this.state.focused_index == null ? 1 : this.state.focused_index;
    if (this.newTagsAllowed && focused_index == -1) focused_index = this.state.candidates.length;
    focused_index -= 1;
    if ( focused_index < 0 ) focused_index = 0;
    this.setState({focused_index: focused_index, selected_candidate: this.state.candidates[focused_index]});
  }

  keyFocusNext(ev) {
    if (this.newTagsAllowed && this.state.focused_index == -1) return;

    var focused_index = this.state.focused_index == null ? -1 : this.state.focused_index;
    focused_index += 1;
    if ( focused_index >= this.state.candidates.length ) {
      if ( this.newTagsAllowed ) {
        this.setState({focused_index: -1, selected_candidate: null});
        return;
      }
      focused_index = this.state.candidates.length - 1;
    }
    this.setState({focused_index: focused_index, selected_candidate: this.state.candidates[focused_index]});
  }

  keySelect(ev) {
    this.confirmCandidate();
  }

  onFieldKeyUp(ev) {
    if ( 38 == ev.keyCode || 40 == ev.keyCode || 27 == ev.keyCode || 13 == ev.keyCode ) {
      return;
    }

    if ( this.candidateRefreshTimeout ) {
      clearTimeout(this.candidateRefreshTimeout);
    }
    this.candidateRefreshTimeout = setTimeout(this.refreshCandidates.bind(this, ev.target), 100);
  }

  onFieldKeyDown(ev) {
    var func = {
      38: this.keyFocusPrev,
      40: this.keyFocusNext,
      13: this.keySelect,
      //27: keyHide,
    }[ev.keyCode];
    console.log(ev.keyCode, ev);
    if (func) func.bind(this)(ev);
  }

  // -----------------------------------------------

  onMenuMouseOver() {
    this.setState({candidates_hovered: true});
  }

  onMenuMouseOut() {
    this.setState({candidates_hovered: false});
  }

  // -----------------------------------------------

  onFocusAfterFinalize() {
    this.notifyChange(null);
    this.setState({
      form_disabled: false,
      confirmed_value: null,
    });
  }

  onFocus() {
    this.setState({form_focused: true});
  }

  onBlur() {
    this.setState({form_focused: false});
  }

  onChange(ev) {
    this.setState({form_value: ev.target.value});
  }

  // -----------------------------------------------

  render() {
    if (this.state.confirmed_value) {
      var inner = (
        <input type="input" className={this.props.className} onClick={this.onFocusAfterFinalize.bind(this)} value={this.state.confirmed_value.name} disabled={true} style={{cursor: 'text'}} />
      );
    } else {
      var inner = (
        <input placeholder={this.props.placeholder || 'Tag...'} type="input" className={this.props.className} onKeyDown={this.onFieldKeyDown.bind(this)} onKeyUp={this.onFieldKeyUp.bind(this)} onFocus={this.onFocus.bind(this)} onBlur={this.onBlur.bind(this)} onChange={this.onChange.bind(this)} value={this.state.form_value} disabled={this.state.form_disabled} autoFocus={this.props.autoFocus} />
      );
    }

    return (
      <div className={this.mainClassName}>
        {inner}
        <div className="tag-selector-candidates" style={this.showCandidates ? {} : {display: "none"}} onMouseOver={this.onMenuMouseOver.bind(this)} onMouseOut={this.onMenuMouseOut.bind(this)}>
          {this.candidateElems}
        </div>
      </div>
    );
  }
}
