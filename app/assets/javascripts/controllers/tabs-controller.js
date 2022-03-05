import { Controller } from 'stimulus';
import tabsForm from './tabs/form';

const errorClass = 'has-errors';

export default class extends Controller {
  static targets = ['list', 'tab', 'form'];

  connect() {
    this.listItems = Array.from(this.listTarget.children);
    this.tabsCount = this.tabTargets.length;
    if (this.hasFormTarget) {
      this.form = tabsForm(this.formTarget);
    }
    if (this.listItems.length > 0) {
      const activeIndex = this.findActiveIndex();
      const activeTab = activeIndex > -1 ? this.listItems[activeIndex] : this.listItems[0];
      this.changeTab(activeTab);
    }
  }

  async onSelectorClick(ev) {
    ev.preventDefault();
    await this.changeTab(ev.currentTarget.parentNode);
    this.scrollToTab();
  }

  async nextTab(ev) {
    if (this.activeIndex + 1 === this.tabsCount) return;

    ev.preventDefault();

    await this.changeTab(this.listItems[this.activeIndex + 1]);
    this.scrollToTab();
  }

  async previousTab(ev) {
    if (this.activeIndex - 1 < 0) return;

    ev.preventDefault();
    await this.changeTab(this.listItems[this.activeIndex - 1]);
    this.scrollToTab();
  }

  async changeTab(target) {
    const tabIndex = this.findIndex(target);
    if (tabIndex > -1 && tabIndex < this.tabsCount) {
      let switchTo = tabIndex;
      if (tabIndex > this.activeIndex) {
        switchTo = await this.firstInvalidTab(this.activeIndex, tabIndex);
      }
      this.activeIndex = switchTo;
      this.markTabActive();
      this.switchTabTo();
    }
  }

  findIndex(tab) {
    return this.listItems.findIndex((item) => item === tab);
  }

  findActiveIndex() {
    const index = this.listItems.findIndex((item) => item.classList.contains('active'));
    return index > -1 ? index : this.listItems.length - 1 - index;
  }

  markTabActive() {
    this.listItems.forEach((item, idx) => {
      if (idx > this.activeIndex) {
        item.classList.remove('active');
      } else {
        item.classList.add('active');
      }
    });
  }

  switchTabTo() {
    this.tabTargets.forEach((tab) => {
      tab.classList.add('hidden');
    });
    this.tabTargets[this.activeIndex].classList.remove('hidden');
  }

  scrollToTab() {
    const { target, block } = this.findScrollingTarget();
    target.scrollIntoView({ behavior: 'smooth', block });
  }

  findScrollingTarget() {
    const activeTab = this.tabTargets[this.activeIndex];

    if (!this.form) return activeTab;

    const fieldWithErrors = activeTab.querySelector(`.${errorClass}`);

    if (fieldWithErrors) return { target: fieldWithErrors, block: 'center' };

    return { target: activeTab, block: 'start' };
  }

  async firstInvalidTab(stepFrom, stepTo) {
    if (!this.form) return true;
    const steps = [];
    for (let i = stepFrom; i < stepTo; i += 1) steps.push(this.tabTargets[i]);

    const lastValidIndex = await this.form.findFirstInvalidTab(steps);

    return stepFrom + lastValidIndex;
  }
}
