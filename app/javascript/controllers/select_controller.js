import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['imagesLabel', 'imagesFileField']

  toggleUpload(event) {
    if (event.target.value == 'Yes') {
      this.imagesFileFieldTarget.required = true
      this.imagesLabelTarget.classList.add('required')
    } else {
      this.imagesFileFieldTarget.required = false
      this.imagesLabelTarget.classList.remove('required')
    }

  }
}
