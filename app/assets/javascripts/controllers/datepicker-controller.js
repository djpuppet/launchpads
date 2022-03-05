import { Controller } from 'stimulus';
import { parse } from 'date-fns';
import { Datepicker } from 'vanillajs-datepicker';

export default class extends Controller {
  static targets = ['input'];

  connect() {
    this.dateFormat = this.data.has('format') ? this.data.get('format') : 'mm-dd-yyyy';
    this.minDate = this.data.has('minDate')
      ? parse(this.data.get('minDate'), this.dateFormat, new Date())
      : new Date('01-01-1980');
    this.maxDate = this.data.has('maxDate')
      ? parse(this.data.get('maxDate'), this.dateFormat, new Date())
      : new Date('01-01-2030');
    this.initDatepicker();
    if (this.inputTarget.value) {
      this.instance.setDate(this.inputTarget.value, { render: false, clear: true });
    }
  }

  initDatepicker() {
    this.instance = new Datepicker(this.inputTarget, {
      format: this.dateFormat,
      minDate: this.minDate,
      maxDate: this.maxDate,
      todayBtn: true,
    });
    this.instance.refresh = this.refreshWithUpdateOnBlur();
  }

  refreshWithUpdateOnBlur() {
    const { dateFormat } = this;
    const { refresh } = this.instance;

    return (target = undefined) => {
      if (target === 'input' && this.instance.getDate(dateFormat) !== this.inputTarget.value) {
        this.instance.setDate([this.inputTarget.value], { clear: true, render: false });
      }
      refresh.bind(this.instance)(target);
    };
  }

  show(ev) {
    ev.preventDefault();
    if (this.instance.active) {
      this.instance.hide();
    } else {
      this.instance.show();
    }
  }

  keyup() {
    const date = this.inputTarget.value;

    if (date.length !== this.dateFormat.length) return;

    this.instance.setDate(date);
    if (this.instance.getDate(this.dateFormat) !== date) {
      this.inputTarget.value = date;
    }
  }
}
