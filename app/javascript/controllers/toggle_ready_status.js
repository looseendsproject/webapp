document.addEventListener('turbo:load', function() {
  const statusDropdown = document.getElementById('status-dropdown');
  const readyStatusRow = document.getElementById('ready-status-row');

  function toggleReadyStatus() {
    if (statusDropdown.value === 'ready to match') {
      readyStatusRow.style.display = 'block';
    } else {
      readyStatusRow.style.display = 'none';
    }
  }

  // Check the initial status on page load
  toggleReadyStatus();
  
  // Add event listener for changes in the status dropdown
  statusDropdown.addEventListener('change', toggleReadyStatus);
});
