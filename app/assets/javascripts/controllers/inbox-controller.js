import { Controller } from 'stimulus';
import initTooltip from './tooltip/tooltip';

export default class extends Controller {
  static targets = ['messages', 'messageInput', 'actions', 'form'];

  connect() {
    const height = this.messagesTarget.offsetHeight;
    const { scrollHeight } = this.messagesTarget;
    this.messagesTarget.scrollTo(0, scrollHeight - height);
    this.actions = initTooltip(this.actionsTarget);
    this.conversationKey = this.formTarget.getAttribute('action');
    this.messageContent = this.storedMessage;
    this.messageChange();
  }

  disconnect() {
    this.actions.destroy();
  }

  submitMessage(ev) {
    if (this.messageContent.length === 0) {
      ev.preventDefault();
      ev.stopPropagation();
      this.messageContent = '';
    }
    this.storedMessage = '';
  }

  showActions(ev) {
    ev.preventDefault();
    this.actions.toggle(null, true);
  }

  messageChange() {
    this.storeMessage();
    this.calculateInputHeight();
  }

  storeMessage() {
    this.storedMessage = this.messageContent;
  }

  calculateInputHeight() {
    const styles = window.getComputedStyle(this.messageInputTarget);
    const maxHeight = parseInt(styles.getPropertyValue('max-height'), 10);
    this.element.style.setProperty('--input-height', '0px');
    const height = Math.min(this.messageInputTarget.scrollHeight, maxHeight);
    this.element.style.setProperty('--input-height', `${height}px`);
  }

  get storedMessage() {
    if (!sessionStorage) return '';

    const item = sessionStorage.getItem(this.conversationKey);

    return item || '';
  }

  set storedMessage(content) {
    if (!sessionStorage) return;

    sessionStorage.setItem(this.conversationKey, content);
  }

  get messageContent() {
    return this.messageInputTarget.value.trim();
  }

  set messageContent(content) {
    this.messageInputTarget.value = content;
  }
}
