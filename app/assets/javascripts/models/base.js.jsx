"use strict";

class ApiBase {
  constructor(props) {
    jQuery.extend(this, props);


    if ( this._links ) {
      Object.getOwnPropertyNames(this._links).forEach((rel) => {
        var link = this._links[rel];
        if (!link.hasOwnProperty('rel')) link.rel = rel;
        this.constructor.giveLinkMethods(link);
      });
    }

    var collectionClasses = this.constructor.collectionClasses();
    Object.getOwnPropertyNames(collectionClasses).forEach((propName) => {
      var collectionClass = collectionClasses[propName];
      if ( ! (this[propName] && this[propName].map) ) return;

      this[propName] = this[propName].map((x) => { return new collectionClass(x) });
    });
  }

  put(params) {
    return this._links.self.put(params);
  }

  get(params) {
    return this._links.self.get(params);
  }

  static path() {
    return "";
  }

  static index(params) {
    return this.get(null, params);
  }

  static get(subpath, params) {
    return this.request('GET', subpath, params)
  }

  static put(subpath, params) {
    return this.request('PUT', subpath, params)
  }

  static post(subpath, params) {
    return this.request('POST', subpath, params)
  }

  static request(method, subpath, params) {
    var klass = this;
    var path;
    if (subpath && subpath !== '')  {
      if (subpath[0] == '/') {
        path = subpath;
      } else {
        path = `${this.path()}/${subpath}`;
      }
    } else {
      path = this.path();
    }

    var p = new Promise((resolve, reject) => {
      $.ajax({
        url: path,
        method: method,
        dataType: 'json',
        data: params,
      }).done((data, textStatus, xhr) => resolve([data, textStatus, xhr]))
        .fail((xhr, textStatus, err)  => reject(err));
    })

    return p.then((ary) => {
      var data = ary[0];
      var textStatus = ary[1];
      var xhr = ary[2];

      var mappedData;
      if ( data.map ) {
        mappedData = data.map((x) => { return new klass(x) });
      } else {
        mappedData = new klass(data);
      }

      var count;
      var countHeader = xhr.getResponseHeader('X-List-Totalcount');
      if (countHeader && countHeader !== "") {
        count = parseInt(countHeader, 10);
      }

      return {
        data: mappedData,
        count: count,
        "_links": klass.parseLinkHeader(xhr.getResponseHeader('Link')),
      };
    });
  }

  static collectionClasses() {
    return {};
  }

  static linkedClasses() {
    return {};
  }

  static resolveLinkedClass(rel) {
    var dic = this.linkedClasses();
    if (!dic.hasOwnProperty('prev')) dic.prev = this;
    if (!dic.hasOwnProperty('next')) dic.next = this;
    if (!dic.hasOwnProperty('self')) dic.self = this;

    return dic[rel] || ApiBase;
  }

  static giveLinkMethods(link) {
    link.get = (params) => { return this.resolveLinkedClass(link.rel).get(link.href, params) };
    link.post = (params) => { return this.resolveLinkedClass(link.rel).post(link.href, params) };
    link.put = (params) => { return this.resolveLinkedClass(link.rel).put(link.href, params) };
  }

  static parseLinkHeader(header) {
    if ( !header || header == "" ) {
      return {};
    }

    var klass = this;
    var links = header.split(/, ?/);

    return links.reduce((linksObj, link) => {
      var parts = link.split(/; ?/);
      var obj = {
        href: parts.shift().replace(/^</, '').replace(/>$/, ''),
      };

      parts.forEach((part) => {
        var lr = part.split(/=/)
        var key = lr[0];
        var val = lr[1];

        if(val[0] == '"') {
          val = val.replace(/^"/, '').replace(/"$/, '').replace(/\\"/g, '"');
        }
        obj[key] = val;
      });

      klass.giveLinkMethods(obj);

      if ( ! linksObj[obj.rel] ) {
        linksObj[obj.rel] = obj;
      }

      return linksObj;
    }, {});
  }
}
