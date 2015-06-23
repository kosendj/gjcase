"use strict";

class Image {
  static find(id) {
    return new Promise((ok, rej) => {
      var encodedId = encodeURIComponent(id)
      $.getJSON(`/images/${encodedId}.json`, params || {}
      ).done((data) => {
        ok(data.map((x) => new Image(x)))
      }).fail((err) => {
        rej(err)
      })
    });
  }

  static list(params) {
    return new Promise((ok, rej) => {
      $.getJSON('/images.json', params || {}
      ).done((data) => {
        ok(data.map((x) => new Image(x)))
      }).fail((err) => {
        rej(err)
      })
    });
  }

  constructor(obj) {
    this.id = obj.id
    this.source_url = obj.source_url
    this.image_url = obj.image_url
    this.comment = obj.comment
    this.tags = (obj.tags || []).map((tag) => new Tag(tag))
  }
}
