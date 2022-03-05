import { Controller } from 'stimulus';
import createFocusTrap from 'focus-trap';
import isChild from '../utils/is-child';

export default class extends Controller {
  static targets = ['overlay', 'wrapper', 'content', 'template'];

  initialize() {
    this.handleTurbolinksClick = this.handleTurbolinksClick.bind(this);
    this.followHashName = this.followHashName.bind(this);
    this.name = this.data.get('name');
  }

  connect() {
    this.content = null;
    this.isOpen = false;
    this.closeable = this.data.has('closeable');
    this.createFocusTrap();
    window.addEventListener('hashchange', this.followHashName);
    if (this.element.classList.contains('open')) {
      this.setHash();
    }
    this.followHashName();
  }

  disconnect() {
    this.removeContent();
    window.removeEventListener('hashchange', this.followHashName);
    this.focusTrap.deactivate();
  }

  createFocusTrap() {
    this.focusTrap = createFocusTrap(this.wrapperTarget, {
      fallbackFocus: this.element,
      escapeDeactivates: this.closeable,
      clickOutsideDeactivates: this.closeable,
      onActivate: () => {
        this.closeOtherModals();
        if (this.hasTemplateTarget) {
          this.contentFromTemplate();
        }
        if (this.closeable) {
          this.listenToClicks();
        }
        this.show();
      },
      onDeactivate: () => {
        this.stopListenToClicks();
        this.hide();
        this.resetHash();
        this.removeContent();
      },
    });
  }

  open() {
    if (this.isOpen) return;

    this.focusTrap.activate();
  }

  close(ev = null) {
    if (ev) ev.preventDefault();

    if (!this.isOpen) return;

    this.focusTrap.deactivate();
  }

  followHashName() {
    if (this.getHash() === this.name) {
      this.open();
    }
  }

  setHash() {
    window.location.hash = `#${this.name}`;
  }

  resetHash() {
    if (this.getHash() === this.name) {
      window.history.replaceState({}, '', '#');
    }
  }

  show() {
    this.isOpen = true;
    document.body.classList.add('has-modal');
    this.element.classList.add('open');
  }

  hide() {
    this.isOpen = false;
    document.body.classList.remove('has-modal');
    this.element.classList.remove('open');
  }

  contentFromTemplate() {
    this.content = document.createElement('div');
    this.content.appendChild(this.templateTarget.content.cloneNode(true));
    this.contentTarget.insertBefore(this.content, this.templateTarget);
  }

  removeContent() {
    if (this.content) {
      this.contentTarget.removeChild(this.content);
      this.content = null;
    }
  }

  listenToClicks() {
    document.addEventListener('turbolinks:click', this.handleTurbolinksClick);
  }

  stopListenToClicks() {
    document.removeEventListener('turbolinks:click', this.handleTurbolinksClick);
  }

  handleTurbolinksClick(ev) {
    if (isChild(ev.target, this.element)) {
      this.close();
    }
  }

  getHash() {
    return window.location.hash.slice(1);
  }

  closeOtherModals() {
    const modalControllers = this.application.controllers.filter((el) => this.isOtherModal(el));
    modalControllers.forEach((c) => c.close());
  }

  isOtherModal(el) {
    return el.identifier === this.identifier && el !== this;
  }
}
