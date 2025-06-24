class CharacterCounter {
  constructor(textareaId, counterId, maxLength = 1000) {
    this.textarea = document.getElementById(textareaId);
    this.counter = document.getElementById(counterId);
    this.maxLength = maxLength;
    this.warningThreshold = 0.7;
    this.dangerThreshold = 0.9;
    this.init();
  }
  
  init() {
    if (!this.textarea || !this.counter) {
      console.error('CharacterCounter: Required elements not found');
      return;
    }
    
    this.textarea.addEventListener('input', () => this.updateCount());
    this.updateCount();
  }
  
  updateCount() {
    const currentLength = this.textarea.value.length;
    this.counter.textContent = currentLength;
    this.updateStyle(currentLength);
  }
  
  updateStyle(length) {
    const ratio = length / this.maxLength;
    
    this.counter.className = '';
    
    if (ratio > this.dangerThreshold) {
      this.counter.className = 'text-danger';
    } else if (ratio > this.warningThreshold) {
      this.counter.className = 'text-warning';
    }
  }
}

document.addEventListener('DOMContentLoaded', () => {
  new CharacterCounter('postBody', 'charCount', 1000);
});