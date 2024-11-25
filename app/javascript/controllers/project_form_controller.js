document.addEventListener('turbo:load', function() {
  function setupProjectForm() {
    const groupProjectCheckbox = document.querySelector('#project_group_project');
    const groupManagerRow = document.querySelector('#group-manager-row');
    
    const pressCheckbox = document.querySelector('#project_press');
    const pressFields = document.querySelector('#press-fields');
    
    if (groupProjectCheckbox && groupManagerRow) {
      groupProjectCheckbox.addEventListener('change', function() {
        groupManagerRow.style.display = this.checked ? '' : 'none';
      });
    }
    
    if (pressCheckbox && pressFields) {
      pressCheckbox.addEventListener('change', function() {
        pressFields.style.display = this.checked ? '' : 'none';
      });
    }
  }

  setupProjectForm();
});