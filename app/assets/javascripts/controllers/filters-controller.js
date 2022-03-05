import { Controller } from 'stimulus';
import Turbolinks from '../vendor/turbolinks';

export default class extends Controller {
  static targets = ['list', 'form', 'collection'];

  connect() {
    this.changeDebouncer = null;

    const formData = new FormData(this.formTarget);
    this.filterInputs = [...formData.keys()];
  }

  disconnect() {
    clearTimeout(this.changeDebouncer);
  }

  reset(ev) {
    ev.preventDefault();

    if (!this.filterInputs) return;

    this.filterInputs.forEach((name) => {
      const inputs = this.formTarget.querySelectorAll(`[name="${name}"]`);
      if (inputs.length) {
        this.resetInputValue([...inputs]);
      }
    });
  }

  toggleFilters(ev) {
    ev.preventDefault();
    if (this.isOpen()) {
      this.close();
    } else {
      this.open();
    }
  }

  change() {
    clearTimeout(this.changeDebouncer);
    this.changeDebouncer = setTimeout(this.submitFiltersForm.bind(this), 500);
  }

  open() {
    this.listTarget.classList.remove('hidden');
  }

  close() {
    this.listTarget.classList.add('hidden');
  }

  isOpen() {
    return !this.listTarget.classList.contains('hidden');
  }

  submitFiltersForm() {
    const url = new URL(this.formTarget.action);
    const urlParams = new URLSearchParams(url.search);
    const formData = new FormData(this.formTarget);
    [...formData.entries()].forEach(([key, value]) => {
      urlParams.append(key, value);
    });
    url.search = urlParams.toString();

    Turbolinks.visit(url);
  }

  resetInputValue(inputs) {
    const value = inputs[inputs.length - 1].dataset.initialValue;
    if (!value) return;

    if (inputs.length > 1) {
      // checkbox/radio
      inputs.forEach((input) => {
        // eslint-disable-next-line no-param-reassign
        input.checked = input.value === value;
      });
    } else {
      // generic input
      // eslint-disable-next-line no-param-reassign
      inputs[0].value = value;
    }
    inputs[inputs.length - 1].dispatchEvent(new InputEvent('change', { bubbles: true }));
  }
}
