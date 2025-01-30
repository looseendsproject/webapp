import { Controller } from "@hotwired/stimulus";

// Define the value of status we care to act on. Defined at the top for easy reference
// and to catch any typos in the future.
const statusValues = {
  ready: 'ready to match',
  inProcess: 'in process'
};

export default class extends Controller {
  static targets = ["status", "readyStatus", "inProcessStatus"];

  connect() {
    // Apply current value on initial page load
    this.applyStatus(this.statusTarget.value);
  }

  statusChanged(event) {
    // Apply the new value when the select changes
    this.applyStatus(event.target.value);
  }

  applyStatus(status) {
    if (status === statusValues.ready) {
      this.readyStatusTarget.style.display = 'block';
      this.inProcessStatusTarget.style.display = 'none';
    } else if (status === statusValues.inProcess) {
      this.readyStatusTarget.style.display = 'none';
      this.inProcessStatusTarget.style.display = 'block';
    } else {
      this.readyStatusTarget.style.display = 'none';
      this.inProcessStatusTarget.style.display = 'none';
    }
  }
}