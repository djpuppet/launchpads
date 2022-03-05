import { Controller } from 'stimulus';
import isChild from '../utils/is-child';
import emitEvent from '../utils/emit-event';

export default class extends Controller {
  static targets = ['input', 'option', 'placeholder', 'rootElement'];

  initialize() {
    this.handleFocus = this.handleFocus.bind(this);
    this.handleArrowsPress();
  }

  connect() {
    this.handleOutsideClick = this.handleOutsideClick.bind(this);
    this.isMultiple = this.data.has('multiple');
    this.disabled = this.data.has('disabled');
    this.options = Array.from(this.inputTarget.options);
    const selected = this.options
      .filter((option) => option.selected && option.value.length)
      .map((option) => [option.value, option]);
    this.selected = new Map(selected);
    this.setInputValue();
    this.setVisibleValue();
  }

  disconnect() {
    this.clearOutsideClickListener();
  }

  labelClick(ev) {
    ev.preventDefault();
    setTimeout(() => this.openDropdown());
  }

  select(ev) {
    this.toggleSelection(ev.target);
    if (!this.isMultiple) {
      this.toggle();
    }
  }

  accessibilityKeypress(ev) {
    switch (ev.key) {
      case 'Enter':
      case ' ':
      case 'ArrowUp':
      case 'ArrowDown':
        ev.preventDefault();
        this.openDropdown();
        break;
      default:
    }
  }

  handleArrowsPress() {
    window.addEventListener('keydown', (ev) => {
      if ((ev.key === 'ArrowUp' || ev.key === 'ArrowDown') && this.isFocused(this.rootElementTarget)) {
        this.accessibilityKeypress(ev);
      }
    });
  }

  handleOutsideClick(ev) {
    if (!isChild(ev.target, this.rootElementTarget)) {
      this.closeDropdown();
    }
  }

  attachOutsideClickListener() {
    document.body.addEventListener('click', this.handleOutsideClick);
  }

  clearOutsideClickListener() {
    document.body.removeEventListener('click', this.handleOutsideClick);
  }

  toggle() {
    if (this.disabled) return;

    if (this.rootElementTarget.classList.contains('open')) {
      this.closeDropdown();
    } else {
      this.openDropdown();
    }
  }

  openDropdown() {
    this.changed = false;
    this.attachOutsideClickListener();
    this.rootElementTarget.classList.add('open');
    this.moveFocus(1);
    this.startHandlingFocus();
  }

  closeDropdown() {
    if (this.changed) {
      emitEvent(this.inputTarget, 'change');
    }
    this.clearOutsideClickListener();
    this.rootElementTarget.classList.remove('open');
    this.stopHandlingFocus();
    if (isChild(document.activeElement, this.rootElementTarget)) {
      this.rootElementTarget.focus();
    }
  }

  toggleSelection(selection) {
    const value = this.findSelectionValue(selection);

    if (this.isMultiple) {
      this.setMultipleSelection(value, selection);
    } else {
      this.setSingleSelection(value, selection);
    }
  }

  setSingleSelection(value, selection) {
    this.selected.clear();

    if (value !== '') {
      this.selected.set(value, selection);
    }
    this.setInputValue();
    this.setVisibleValue();
  }

  setMultipleSelection(value, selection) {
    if (this.selected.has(value)) {
      this.selected.delete(value);
    } else {
      this.selected.set(value, selection);
    }
    this.setInputValue();
    this.setVisibleValue();
  }

  setInputValue() {
    this.options.forEach((option) => {
      // eslint-disable-next-line no-param-reassign
      option.selected = Boolean(option.value.length && this.selected.has(option.value));
    });
    this.changed = true;
  }

  setVisibleValue() {
    let value = this.constructVisibleValue();
    if (!value) {
      value = this.inputTarget.options.length > 0 ? this.inputTarget.options[0].innerHTML : '';
      this.placeholderTarget.classList.add('placeholder');
    } else {
      this.placeholderTarget.classList.remove('placeholder');
    }
    this.placeholderTarget.innerHTML = value;
    this.optionTargets.forEach((option) => {
      const key = this.findSelectionValue(option);
      if (key.length && this.selected.has(key)) {
        option.classList.add('selected');
      } else {
        option.classList.remove('selected');
      }
    });
  }

  constructVisibleValue() {
    if (this.selected.size > 0) {
      return Array.from(this.selected.values())
        .map((option) => option.innerHTML.trim())
        .join(', ');
    }

    return false;
  }

  findSelectionValue(selection) {
    if (!selection.dataset || !selection.dataset.dropdownValue) return '';

    return selection.dataset.dropdownValue;
  }

  handleFocus(ev) {
    switch (ev.key) {
      case 'Tab':
        ev.preventDefault();
        break;
      case 'Enter':
        ev.preventDefault();
        this.checkFocused();
        this.closeDropdown();
        break;
      case ' ':
        ev.preventDefault();
        this.checkFocused();
        break;
      case 'Escape':
        ev.preventDefault();
        this.closeDropdown();
        break;
      case 'ArrowDown':
        ev.preventDefault();
        this.moveFocus(1);
        break;
      case 'ArrowUp':
        ev.preventDefault();
        this.moveFocus(-1);
        break;
      default:
    }
  }

  startHandlingFocus() {
    document.body.addEventListener('keydown', this.handleFocus);
  }

  stopHandlingFocus() {
    document.body.removeEventListener('keydown', this.handleFocus);
  }

  checkFocused() {
    const focused = this.findFocusedOption();
    if (!this.isMultiple) {
      this.closeDropdown();
    }

    if (focused < 0) return;

    this.toggleSelection(this.optionTargets[focused]);
  }

  moveFocus(direction) {
    if (!this.hasOptionTarget) return;

    let focused = this.findFocusedOption();
    if (direction > 0) {
      this.focusElement((focused + 1) % this.optionTargets.length);
    } else {
      if (focused < 0) focused = this.optionTargets.length;
      this.focusElement((this.optionTargets.length + focused + direction) % this.optionTargets.length);
    }
  }

  focusElement(index) {
    if (this.optionTargets[index]) {
      this.optionTargets[index].focus();
    }
  }

  findFocusedOption() {
    if (!this.hasOptionTarget) return -1;
    if (!document.activeElement) return 0;

    return Array.from(this.optionTargets).findIndex(this.isFocused);
  }

  isFocused(element) {
    return element === document.activeElement;
  }
}
