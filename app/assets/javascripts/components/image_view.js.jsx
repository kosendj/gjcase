"use strict";

class ImageView extends React.Component {
  get image() {
    return this.props.image;
  }

  get tagElems() {
    return (this.image.tags || []).map((tag) => {
      return <span className="label label-default tag-label" key={`tag-${tag.id}`} >{tag.name}</span>
    });
  }

  get className() {
    return "image-view image" + (this.props.selected ? ' selected-image' : '');
  }

  onClick() {
    this.props.onImageSelection(this.image, !this.props.selected);
  }

  render() {
    return <div className={this.className} onClick={this.onClick.bind(this)}>
      <img src={this.image.image_url} />
      <div className="image-comment">
        {this.tagElems}
        {this.image.comment}
      </div>
    </div>
  }
}
