// Small admin UI helper functions
function confirmDelete(id, btn, resource = 'product') {
  if (!id) {
    alert('No id provided for delete');
    return;
  }
  if (!confirm('Are you sure you want to delete this item?')) return;

  const url = `/delete-${resource}/${id}`;
  fetch(url, { method: 'DELETE' })
    .then(res => res.json())
    .then(data => {
      if (data && data.message) {
        // remove the row from the table
        const row = btn.closest('tr');
        if (row) row.remove();
        alert(data.message);
      } else if (data && data.error) {
        alert('Error: ' + data.error);
      } else {
        alert('Deleted (server returned unexpected response)');
        const row = btn.closest('tr');
        if (row) row.remove();
      }
    })
    .catch(err => {
      console.error(err);
      alert('Delete failed: ' + err);
    });
}

// Client-side filter for sub-categories table
function filterSubCategories() {
  const parentVal = (document.getElementById('parentFilter') || {}).value || '';
  const query = (document.getElementById('searchFilter') || {}).value || '';
  const q = query.toLowerCase().trim();
  const rows = document.querySelectorAll('.table-section tbody tr');
  rows.forEach(r => {
    const parent = (r.dataset.parent || '').toString();
    const name = (r.dataset.name || '').toString().toLowerCase();

    let show = true;
    if (parentVal) {
      show = (parent === parentVal);
    }
    if (show && q) {
      show = name.indexOf(q) !== -1;
    }

    r.style.display = show ? '' : 'none';
  });
}

// Client-side search for categories
function filterCategories() {
  const q = (document.getElementById('searchCategories') || {}).value || '';
  const term = q.toLowerCase().trim();
  const rows = document.querySelectorAll('.table-section tbody tr');
  rows.forEach(r => {
    const name = (r.dataset.name || '').toString().toLowerCase();
    const show = !term || name.indexOf(term) !== -1;
    r.style.display = show ? '' : 'none';
  });
}

// Lazy-load images using IntersectionObserver or fallback
function initLazyLoad() {
  const lazyImages = [].slice.call(document.querySelectorAll('img.lazy-img'));
  if ('IntersectionObserver' in window) {
    let observer = new IntersectionObserver(function(entries, observer) {
      entries.forEach(function(entry) {
        if (entry.isIntersecting) {
          let img = entry.target;
          if (img.dataset && img.dataset.src) {
            img.src = img.dataset.src;
            img.removeAttribute('data-src');
          }
          img.classList.remove('lazy-img');
          observer.unobserve(img);
        }
      });
    });
    lazyImages.forEach(function(img) { observer.observe(img); });
  } else {
    // Fallback: load all images
    lazyImages.forEach(function(img) {
      if (img.dataset && img.dataset.src) img.src = img.dataset.src;
      img.classList.remove('lazy-img');
    });
  }
}

// Client-side pagination for tables
function setupPagination(tableId, pageSize = 20) {
  const table = document.getElementById(tableId);
  if (!table) return;
  const tbody = table.querySelector('tbody');
  const rows = Array.from(tbody.querySelectorAll('tr'));
  if (rows.length <= pageSize) return;

  let currentPage = 1;
  const totalPages = Math.ceil(rows.length / pageSize);

  const pager = document.createElement('div');
  pager.className = 'pager';
  function renderPager() {
    pager.innerHTML = '';
    const info = document.createElement('span');
    info.textContent = `Page ${currentPage} / ${totalPages}`;
    pager.appendChild(info);
    const prev = document.createElement('button'); prev.textContent = 'Prev';
    prev.disabled = currentPage === 1; prev.onclick = () => { currentPage--; showPage(); };
    const next = document.createElement('button'); next.textContent = 'Next';
    next.disabled = currentPage === totalPages; next.onclick = () => { currentPage++; showPage(); };
    pager.appendChild(prev); pager.appendChild(next);
  }

  function showPage() {
    const start = (currentPage - 1) * pageSize;
    const end = start + pageSize;
    rows.forEach((r, i) => { r.style.display = (i >= start && i < end) ? '' : 'none'; });
    renderPager();
    initLazyLoad();
    formatDates();
  }

  table.parentNode.insertBefore(pager, table.nextSibling);
  showPage();
}

document.addEventListener('DOMContentLoaded', function() {
  initLazyLoad();
  // setup pagination where appropriate
  setupPagination('subCategoriesTable', 20);
  setupPagination('categoriesTable', 20);
  // wire offers pagination (page size may be changed by user)
  const offersTable = document.getElementById('offersTable');
  if (offersTable) {
    const pageSizeSelect = document.getElementById('offersPageSize');
    const startPageSize = pageSizeSelect ? parseInt(pageSizeSelect.value, 10) : 20;
    setupPagination('offersTable', startPageSize);
    if (pageSizeSelect) {
      pageSizeSelect.addEventListener('change', function() {
        // remove existing pager and recreate with new page size
        const pager = offersTable.parentNode.querySelector('.pager');
        if (pager) pager.remove();
        setupPagination('offersTable', parseInt(this.value, 10));
      });
    }
    // wire search
    const search = document.getElementById('searchOffers');
    if (search) search.addEventListener('input', filterOffers);
    // initial formatting
    formatDates();
  }
});

// Format ISO date strings into human-friendly locale strings
function formatDates() {
  const els = document.querySelectorAll('.iso-date');
  els.forEach(el => {
    const txt = (el.textContent || '').trim();
    if (!txt) return;
    // avoid re-formatting if already converted
    if (el.dataset.formatted === '1') return;
    try {
      const d = new Date(txt);
      if (!isNaN(d)) {
        el.textContent = d.toLocaleString();
        el.dataset.formatted = '1';
      }
    } catch (e) {
      // leave as-is
    }
  });
}

// Filter offers table by title, productId, or id
function filterOffers() {
  const q = (document.getElementById('searchOffers') || {}).value || '';
  const term = q.toLowerCase().trim();
  const rows = document.querySelectorAll('#offersTable tbody tr');
  rows.forEach(r => {
    const title = (r.querySelector('td') || {}).textContent || '';
    const product = (r.querySelectorAll('td')[1] || {}).textContent || '';
    const id = (r.querySelectorAll('td')[5] || {}).textContent || '';
    const show = !term || title.toLowerCase().indexOf(term) !== -1 || product.toLowerCase().indexOf(term) !== -1 || id.toLowerCase().indexOf(term) !== -1;
    r.style.display = show ? '' : 'none';
  });
}
