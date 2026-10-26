// main.js - SWMRS Glassy UI Helper Scripts

function toggleSqlDrawer() {
  const panel = document.getElementById('sqlDrawerPanel');
  if (panel) {
    if (panel.style.display === 'none' || panel.style.display === '') {
      panel.style.display = 'block';
    } else {
      panel.style.display = 'none';
    }
  }
}

// Auto-dismiss alerts after 4 seconds
document.addEventListener('DOMContentLoaded', () => {
  const alerts = document.querySelectorAll('.alert-dismissible');
  alerts.forEach(alert => {
    setTimeout(() => {
      const bsAlert = new bootstrap.Alert(alert);
      bsAlert.close();
    }, 4500);
  });
});
