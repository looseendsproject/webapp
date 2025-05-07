import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['upload']

  toggleUploadVisible(event) {
    if (event.target.value == 'Yes') {
      this.uploadTarget.hidden = false
    } else {
      this.uploadTarget.hidden = true
    }

  }
}
