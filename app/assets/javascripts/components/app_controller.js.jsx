"use strict";

class AppController extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      images_response: null,
      per_page: 18,
      page: 1,
      tags: null,
      selected_images: {},
    };

    this.loadImages();
  }

  get maxPage() {
    if ( ! this.state.images_response ) {
      return 0;
    }

    return Math.ceil(this.state.images_response.count / this.state.per_page);
  }

  loadImages(params) {
    params = params || {};

    params.per_page = params.per_page || this.state.per_page;
    params.page = params.page || this.state.page;
    params.tags = params.hasOwnProperty('tags') ? params.tags : this.state.tags;
    params.fields = '__default__,tags';

    console.log(params);

    this.setState({working: true});

    GjcaseImage.index(params).then((response) => {
      this.setState({
        working: false,
        selected_images: {},
        images_response: response,
        per_page: params.per_page,
        page: params.page,
        tags: params.tags,
      });
    });
  }

  onToolbarButton(name) {
    var func = {
      bulk_tag_add: this.openBulkTagAdd,
      send_gj: this.sendToGJ,
    }[name]

    func.bind(this)();
  }

  openBulkTagAdd() {
    this.setState({pane_bulk_tag_add: true});
  }

  sendToGJ(dj) {
    var urls = Object.getOwnPropertyNames(this.state.selected_images).map((image_id) => {
      var image = this.state.selected_images[image_id];
      return image.image_url;
    });

    var params = {urls: urls, dj: dj ? 'true' : 'false'};

    var p = new Promise((resolve, reject) => {
      $.ajax({
        url: `${document.body.dataset.gjUrl}/gifs`,
        method: 'POST',
        data: params,
      }).done((data, textStatus, xhr) => resolve([data, textStatus, xhr]))
        .fail((xhr, textStatus, err)  => reject(err));
    });
    p.then((x) => {
      console.log(x);
      this.setState({selected_images: {}});
    });
  }

  onTagChange(tag) {
    console.log(tag);
    if (tag) {
      this.loadImages({tags: tag.id, page: 1});
    } else {
      this.loadImages({tags: null, page: 1});
    }
  }

  onPaginate(goNext) {
    var newPage = this.state.page + (goNext ? 1 : -1);
    if (newPage < 1) newPage = 1;

    this.loadImages({page: newPage});
  }

  doLuckyPage(page) {
    this.loadImages({page: Math.floor( Math.random() * (this.maxPage + 1) )});
  }

  onImageSelection(image, selected) {
    var selectedImages = this.state.selected_images;
    
    if (selected) {
      selectedImages[image.id] = image;
    } else {
      delete selectedImages[image.id]
    }

    this.setState({selected_images: selectedImages});
  }

  get paneElems() {
    var elems = [];

    if (this.state.pane_bulk_tag_add) {
      var complete = function() {
        this.setState({pane_bulk_tag_add: false});
        this.loadImages();
      }
      elems.push(
        <BulkTagAddPane key="bulktagadd" images={this.state.selected_images} onComplete={complete.bind(this)}/>
      );
    }

    return elems;
  }

  render() {
    return (
      <div className="container-fluid app-view">
        <header>
          <div className="row align-vertical">
            <div className="col-md-1">
              <h1>gjcase</h1>
              <WorkingIndicator run={this.state.working} />
            </div>
            <div className="col-md-8">
              <Toolbar onButton={this.onToolbarButton.bind(this)} onTagChange={this.onTagChange.bind(this)} />
            </div>
            <div className="col-md-3">
              <Paginator doLucky={this.doLuckyPage.bind(this)} onPaginate={this.onPaginate.bind(this)} count={this.state.images_response && this.state.images_response.count} perPage={this.state.per_page} page={this.state.page} maxPage={this.maxPage} />
            </div>
          </div>
        </header>

        {this.paneElems}

        <ImageCollectionView images={this.state.images_response ? this.state.images_response.data : []} selectedImages={this.state.selected_images} onImageSelection={this.onImageSelection.bind(this)} />
      </div>
    );
  }
};
