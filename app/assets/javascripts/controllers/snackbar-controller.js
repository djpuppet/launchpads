import { Controller } from 'stimulus';

export default class extends Controller {
  close(ev) {
    ev.preventDefault();
    this.element.parentNode.removeChild(this.element);
  }
}
