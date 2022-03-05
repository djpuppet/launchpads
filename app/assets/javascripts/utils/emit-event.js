import 'custom-event-polyfill';

const emitEvent = (node, type, options = {}) => {
  const withDefaults = {
    bubbles: true,
    cancelable: true,
    ...options,
  };
  const event = new CustomEvent(type, withDefaults);
  node.dispatchEvent(event);
};

export default emitEvent;
