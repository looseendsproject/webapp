import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['field', 'value', 'operator', 'predicate']

  connect() {
    this.refresh()
  }

  refresh() {
    const field = this.fieldTarget.value
    const value = this.valueTarget.value.trim()
    const operator = this.operatorTarget.value
    var valueName = value
    if (this.valueTarget.options) {
      valueName = this.valueTarget.options[this.valueTarget.selectedIndex].text
    }

    this.predicateTarget.name = field.toLowerCase()
    if (value) {
      this.updatePredicate(operator, value)
      this.valueTarget.style.width = `${valueName.length + 2}ch`
    } else {
      this.predicateTarget.value = ''
    }
  }

  remove() {
    this.element.remove()
  }

  updatePredicate(operator, value) {
    if (operator === '=') {
      this.predicateTarget.value = value
    } else if (operator === 'before') {
      this.predicateTarget.value = `before(${value})`
    } else if (operator === 'after') {
      this.predicateTarget.value = `after(${value})`
    } else {
      this.predicateTarget.value = `${operator} ${value}`
    }
  }
}