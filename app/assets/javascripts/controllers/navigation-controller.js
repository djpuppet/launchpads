import { Controller } from 'stimulus';
import initTooltip from './tooltip/tooltip';

export default class extends Controller {
  static targets = ['menu'];

  connect() {
    this.tooltip = initTooltip(this.menuTarget);
  }

  disconnect() {
    this.tooltip.destroy();
  }

  toggleMenu(ev) {
    ev.preventDefault();
    this.tooltip.toggle(null, true);
  }

  showTooltip(ev = null) {
    if (ev) {
      ev.preventDefault();
    }
    this.tooltip.show(null, true);
  }

  hideTooltip(ev = null) {
    if (ev) {
      ev.preventDefault();
    }
    this.tooltip.hide();
  }
}
