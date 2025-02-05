import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "hidden"]

  connect() {
    this.url = this.element.dataset.autocompleteUrl;
  }

  fetch(event) {
    const query = event.target.value;
    if (query.length < 2) return; // Only search after 2 characters

    fetch(`${this.url}?term=${encodeURIComponent(query)}`)
      .then(response => response.json())
      .then(data => this.showSuggestions(data));
  }

  showSuggestions(finishers) {
    const list = document.createElement("ul");
    list.classList.add("autocomplete-list");

    finishers.forEach(finisher => {
      const item = document.createElement("li");
      item.textContent = finisher.name;
      item.dataset.id = finisher.id;
      item.dataset.name = finisher.name;
      item.addEventListener("click", (event) => this.selectFinisher(event));
      list.appendChild(item);
    });

    this.clearSuggestions();
    this.element.appendChild(list);
  }

  selectFinisher(event) {
    const finisherName = event.target.dataset.name;
    const finisherId = event.target.dataset.id;

    this.inputTarget.value = finisherName;
    this.hiddenTarget.value = finisherId;

    // Trigger a change event to ensure the form detects the update
    const changeEvent = new Event("change");
    this.hiddenTarget.dispatchEvent(changeEvent);

    this.clearSuggestions();
  }

  clearSuggestions() {
    const existingList = this.element.querySelector(".autocomplete-list");
    if (existingList) existingList.remove();
  }
}
