import { Controller } from "@hotwired/stimulus"

const CopyDelayMs = 1000

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
    navigator.clipboard.writeText(textForCopy)
    this.element.classList.add("copied")
    this.element.textContent = "Copied!"

    setTimeout(() => {
      this.element.classList.remove("copied")
      this.element.textContent
       = textForCopy
    }, CopyDelayMs)
  }
}