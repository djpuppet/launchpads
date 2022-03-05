import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['progress', 'slider', 'labels', 'pluralized'];

  connect() {
    this.rangeMax = this.sliderTarget.max;
    this.rangeMin = this.sliderTarget.min;
    this.labels = Array.from(this.labelsTarget.children);
    this.value = this.sliderTarget.value;
    this.updateUI();
  }

  change() {
    if (this.value !== +this.sliderTarget.value) {
      this.value = this.sliderTarget.value;
      this.updateUI();
    }
  }

  updateUI() {
    const value = this.value - this.rangeMin;
    const progress = Math.round((value / (this.rangeMax - this.rangeMin)) * 100);
    this.progressTarget.style.right = `${100 - progress}%`;
    // eslint-disable-next-line no-unused-expressions
    this.updatePluralized() || this.markLabel(progress);
  }

  markLabel(progress) {
    const labelsCount = this.labels.length - 1;
    if (labelsCount < 0) return;

    const labelIndex = Math.round((progress / 100) * labelsCount);
    this.labels.forEach((label, index) => {
      if (index === labelIndex) {
        label.classList.add('active');
      } else {
        label.classList.remove('active');
      }
    });
  }

  updatePluralized() {
    if (!this.hasPluralizedTarget) {
      return false;
    }

    const { value } = this.sliderTarget;
    this.pluralizedTarget.innerHTML = this.findUnitLabel(value);
    const span = this.pluralizedTarget.querySelector('span');
    if (span) {
      span.innerText = value;
    }

    return true;
  }

  findUnitLabel(value) {
    if (value === this.rangeMin && this.labels[0] && this.labels[0].innerText) {
      return this.labels[0].innerText;
    }
    if (value === this.rangeMax && this.labels[2] && this.labels[2].innerText) {
      return this.labels[2].innerText;
    }
    if (Math.abs(value) === 1) {
      return this.data.get('unit');
    }
    if (this.data.get('unitPlural')) {
      return this.data.get('unitPlural');
    }

    return '<span></span>';
  }

  set value(value) {
    this.inputValue = +value;
  }

  get value() {
    return this.inputValue;
  }
}
