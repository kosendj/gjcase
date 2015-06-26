"use strict";

class ImageCollectionView extends React.Component {
  get imageViews() {
    return (this.props.images || []).map((img) => { return <ImageView image={img} selected={this.props.selectedImages.hasOwnProperty(img.id)} onImageSelection={this.props.onImageSelection} key={img.id}/> })
  }

  render() {
    return <section className="image-collection-view images">
      {this.imageViews}
    </section>
  }
}
