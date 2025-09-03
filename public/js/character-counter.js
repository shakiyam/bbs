'use strict';

document.addEventListener('DOMContentLoaded', function() {
  const textarea = document.getElementById('postBody');
  const counter = document.getElementById('charCount');
  
  if (!textarea || !counter) return;
  
  const maxLength = parseInt(textarea.getAttribute('maxlength'), 10);
  
  function updateCount() {
    const length = textarea.value.length;
    counter.textContent = length;
    
    counter.className = '';
    if (length > maxLength * 0.9) counter.className = 'text-danger';
    else if (length > maxLength * 0.7) counter.className = 'text-warning';
  }
  
  textarea.addEventListener('input', updateCount);
  updateCount();
});