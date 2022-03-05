class Tooltip {
  constructor(target, arrow) {
    this.target = target;
    this.arrow = arrow;
    this.visible = !this.target.classList.contains('hidden');
    this.eventsAttached = false;
    this.handleClick = this.handleClick.bind(this);
    if (this.arrow) {
      this.calculatePosition = this.calculatePosition.bind(this);
      this.calculatePosition();
      window.addEventListener('resize', this.calculatePosition);
      window.addEventListener('orientationchange', this.calculatePosition);
    }
  }

  isOpen() {
    return this.visible;
  }

  calculatePosition() {
    if (!this.arrow) return;

    if (this.activator) {
      const position = this.activator.getBoundingClientRect();
      this.arrow.style.setProperty('--from-left', `${position.left}px`);
    } else {
      this.arrow.style.removeProperty('--from-left');
    }
  }

  destroy() {
    this.clearClickListener();
  }

  show(activator = null, onClickEvent = true) {
    if (activator) {
      this.activator = activator;
      this.activator.classList.add('active');
    }
    this.calculatePosition();
    if (onClickEvent) {
      if (this.visible && !this.eventsAttached) return; // already open by mouseover

      setTimeout(this.attachClickListener.bind(this), 20); // Attach listener after event propagation
    }
    this.target.classList.remove('hidden');
    this.visible = true;
  }

  hide() {
    if (this.activator) {
      this.activator.classList.remove('active');
      this.activator = null;
    }
    this.target.classList.add('hidden');
    this.visible = false;
    this.clearClickListener();
  }

  toggle(activator = null, onClickEvent = true) {
    if (!this.visible) {
      this.show(activator, onClickEvent);
    } else {
      this.hide();
    }
  }

  handleClick() {
    this.hide();
  }

  attachClickListener() {
    if (!this.eventsAttached) {
      document.body.addEventListener('click', this.handleClick);
      this.eventsAttached = true;
    }
  }

  clearClickListener() {
    document.body.removeEventListener('click', this.handleClick);
    this.eventsAttached = false;
  }
}

export default (target, arrow) => {
  return new Tooltip(target, arrow);
};
