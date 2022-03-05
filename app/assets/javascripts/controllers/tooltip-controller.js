import { Controller } from 'stimulus';
import initTooltip from './tooltip/tooltip';

export default class extends Controller {
  static targets = ['bubble', 'arrow'];

  connect() {
    this.tooltip = initTooltip(this.bubbleTarget, this.hasArrowTarget ? this.arrowTarget : null);
  }

  show(ev) {
    setTimeout(() => {
      this.tooltip.show(this.element, ev.type === 'click');
    });
  }

  continue(ev) {
    if (!this.tooltip.isOpen()) {
      ev.preventDefault();
      ev.stopPropagation();
    }
  }

  hide() {
    this.tooltip.hide();
  }
}
