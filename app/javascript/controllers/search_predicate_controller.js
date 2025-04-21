import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['field', 'value', 'operator', 'predicate']

  connect() {
    this.refresh()
  }

  refresh() {
    const field = this.fieldTarget.value
    const value = this.valueTarget.value
    const operator = this.operatorTarget.value

    this.predicateTarget.name = field.toLowerCase()
    if (value.trim()) {
      this.predicateTarget.value = `${operator} ${value.trim()}`
    } else {
      this.predicateTarget.value = ''
    }
  }

  remove() {
    this.element.remove()
  }
}