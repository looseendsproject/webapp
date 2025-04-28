import { Controller } from "@hotwired/stimulus"

const CopyDelayMs = 800
const CopySupportedClass = "copy-supported"
const CopyClass = "copied"

function shouldAppendCopyElement(element) {
  return element.tagName === "A"
}

export default class extends Controller {
  connect() {
    if ("clipboard" in navigator) {
      if (shouldAppendCopyElement(this.element)) {
        this.appendCopyElement()
      } else {
        this.element.classList.add(CopySupportedClass)
        this.element.setAttribute("aria-label", "Copy to clipboard")
        this.element.addEventListener("click", this.copy.bind(this))
      }
    }
  }

  appendCopyElement() {
    if (this.element.querySelector(".copy-supported")) {
      return
    }
    const hiddenTextElement = document.createElement("span")
    hiddenTextElement.style.display = "none"
    hiddenTextElement.textContent = this.element.textContent
    const clipboardLink = document.createElement("span")
    clipboardLink.classList.add("copy-supported")
    clipboardLink.setAttribute("aria-label", "Copy to clipboard")
    clipboardLink.addEventListener("click", this.copy.bind(this))
    clipboardLink.appendChild(hiddenTextElement)
    this.element.appendChild(clipboardLink)
  }

  copy(event) {
    let textForCopy = event.target.textContent
    event.preventDefault()

    if (! this.element.classList.contains(CopySupportedClass)) {
      // Clipboard API not supported or returning errors. Do nothing.
      return
    }

    if (this.element.classList.contains(CopyClass)) {
      // Copy already in progress. Don't copy "Copied!" on double click.
      return
    }

    navigator.clipboard.writeText(textForCopy).then(
      () => {
        this.showCopyFeedback(textForCopy)
      },
      (err) => {
        this.element.classList.remove(CopySupportedClass)
        console.error("Could not copy text: ", err)
      }
    )
  }

  showCopyFeedback(textForCopy) {
    this.element.classList.add(CopyClass)
    this.element.textContent = "Copied!"

    setTimeout(() => {
      this.restoreContent(textForCopy)
    }, CopyDelayMs)
  }

  restoreContent(textForCopy) {
    this.element.classList.remove(CopyClass)
    this.element.textContent = textForCopy
    if (shouldAppendCopyElement(this.element)) {
      this.appendCopyElement()
    }
  }
}
