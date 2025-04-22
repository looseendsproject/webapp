import { Controller } from "@hotwired/stimulus"

const CopyDelayMs = 1000
const CopyClass = "copied"

export default class extends Controller {
  connect() {
    if ("clipboard" in navigator) {
      this.element.classList.add("copy-supported")
      this.element.setAttribute("aria-label", "Copy to clipboard")
      this.element.addEventListener("click", this.copy.bind(this))
    }
  }

  copy(event) {
    let textForCopy = this.element.textContent
    event.preventDefault()

    if (this.element.classList.contains(CopyClass)) {
      // Copy already in progress. Don't copy "Copied!" on double click.
      return
    }

    navigator.clipboard.writeText(textForCopy)
    this.element.classList.add(CopyClass)
    this.element.textContent = "Copied!"

    setTimeout(() => {
      this.element.classList.remove(CopyClass)
      this.element.textContent
       = textForCopy
    }, CopyDelayMs)
  }
}