import { Controller } from 'stimulus';

export default class extends Controller {
  connect() {
    this.recalculateVh();
    window.addEventListener('resize', this.recalculateVh);
    window.addEventListener('orientationchange', this.recalculateVh);
  }

  disconnect() {
    window.removeEventListener('resize', this.recalculateVh);
    window.removeEventListener('orientationchange', this.recalculateVh);
  }

  recalculateVh() {
    document.documentElement.style.setProperty('--vh', `${window.innerHeight / 100}px`);
  }
}
