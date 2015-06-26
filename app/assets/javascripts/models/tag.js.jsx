"use strict";

class GjcaseTag extends ApiBase {
  static path() {
    return "/api/tags";
  }

  static linkedClasses() {
    return {
      "images": GjcaseImage,
    };
  }

  static collectionClasses() {
    return {
      "images": GjcaseImage,
    };
  }
}
