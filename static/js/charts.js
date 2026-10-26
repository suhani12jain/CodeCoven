// charts.js - Chart.js configurations for SWMRS Analytics & Reports

document.addEventListener('DOMContentLoaded', () => {
  // Common Dark Glassy Chart Defaults
  if (typeof Chart !== 'undefined') {
    Chart.defaults.color = '#94a3b8';
    Chart.defaults.borderColor = 'rgba(255, 255, 255, 0.08)';
    Chart.defaults.font.family = "'Inter', sans-serif";

    // 1. Zone Waste Generation Chart
    const zoneChartCanvas = document.getElementById('zoneWasteChart');
    if (zoneChartCanvas) {
      const labels = JSON.parse(zoneChartCanvas.dataset.labels || '[]');
      const values = JSON.parse(zoneChartCanvas.dataset.values || '[]');

      new Chart(zoneChartCanvas, {
        type: 'bar',
        data: {
          labels: labels,
          datasets: [{
            label: 'Total Collected Waste (Kg)',
            data: values,
            backgroundColor: 'rgba(56, 189, 248, 0.65)',
            borderColor: '#38bdf8',
            borderWidth: 1.5,
            borderRadius: 8
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: { display: false }
          },
          scales: {
            y: { beginAtZero: true }
          }
        }
      });
    }

    // 2. Recycling Category Efficiency Doughnut Chart
    const catChartCanvas = document.getElementById('categoryRecyclingChart');
    if (catChartCanvas) {
      const labels = JSON.parse(catChartCanvas.dataset.labels || '[]');
      const rates = JSON.parse(catChartCanvas.dataset.rates || '[]');

      new Chart(catChartCanvas, {
        type: 'doughnut',
        data: {
          labels: labels,
          datasets: [{
            data: rates,
            backgroundColor: [
              'rgba(16, 185, 129, 0.75)',
              'rgba(6, 182, 212, 0.75)',
              'rgba(245, 158, 11, 0.75)',
              'rgba(139, 92, 246, 0.75)',
              'rgba(244, 63, 94, 0.75)',
              'rgba(59, 130, 246, 0.75)',
              'rgba(236, 72, 153, 0.75)'
            ],
            borderColor: 'rgba(255, 255, 255, 0.15)',
            borderWidth: 2
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: { position: 'bottom' }
          }
        }
      });
    }
  }
});
