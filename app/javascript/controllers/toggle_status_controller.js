document.addEventListener('turbo:load', function() {
  const statusDropdown = document.getElementById('status-dropdown');
  const readyStatusRow = document.getElementById('ready-status-row');
  const inProcessStatusRow = document.getElementById('in-process-status-row');

  function toggleReadyStatus() {
    if (statusDropdown.value === 'ready to match') {
      inProcessStatusRow.style.display = 'none';
      readyStatusRow.style.display = 'block';
    } else if (statusDropdown.value === 'in process') {
      readyStatusRow.style.display = 'none';
      inProcessStatusRow.style.display = 'block';
    } else {
      readyStatusRow.style.display = 'none';
      inProcessStatusRow.style.display = 'none';
    }
  }

  // Check the initial status on page load
  toggleReadyStatus();
  
  // Add event listener for changes in the status dropdown
  statusDropdown.addEventListener('change', toggleReadyStatus);
});
