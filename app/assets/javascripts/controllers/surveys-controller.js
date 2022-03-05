import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['form'];

  onChange() {
    this.formTarget.submit();
  }
}
