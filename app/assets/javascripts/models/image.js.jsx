"use strict";

class GjcaseImage extends ApiBase {
  static path() {
    return "/api/images";
  }

  static linkedClasses() {
    return {
      "tags": GjcaseTag,
    };
  }
}
