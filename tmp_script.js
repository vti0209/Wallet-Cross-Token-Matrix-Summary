
    const searchBtn = document.getElementById('searchBtn');
    const exportBtn = document.getElementById('exportBtn');
    const matrixHeader = document.getElementById('matrixHeader');
    const matrixBody = document.getElementById('matrixBody');
    const summaryBadges = document.getElementById('summaryBadges');
    const statusMessage = document.getElementById('statusMessage');
    let currentData = null;

    // Reset trắng toàn bộ form khi vừa load trang
    window.addEventListener('DOMContentLoaded', () => {
      document.getElementById('wallet').value = '';
      document.getElementById('chain').value = '';
      document.getElementById('from_date').value = '';
      document.getElementById('to_date').value = '';
    });

    function formatNumber(value) {
      if (!value || value === 0) return '0';
      return Number(value).toLocaleString('en-US', { minimumFractionDigits: 0, maximumFractionDigits: 4 });
    }

    function buildTable(data) {
      matrixHeader.innerHTML = '';
      matrixBody.innerHTML = '';
      summaryBadges.innerHTML = '';
      statusMessage.textContent = '';
      statusMessage.className = 'status-msg';

      if (!data || !data.tokens || data.tokens.length === 0) {
        statusMessage.textContent = '⚠️ Không tìm thấy dữ liệu giao dịch cho thông số tìm kiếm này.';
        statusMessage.classList.add('error');
        summaryBadges.style.display = 'none';
        return;
      }

      const tokens = data.tokens;
      const matrix = data.matrix;

      // 1. Tạo Tiêu đề Cột
      const titleRow = document.createElement('tr');
      titleRow.innerHTML = '<th>Token / Pool</th>' + tokens.map(t => 
        `<th>${t.symbol}<br><small style="font-weight:normal;color:#64748b;">${t.contract ? '(' + t.contract.slice(0, 6) + '...)' : 'Native'}</small></th>`
      ).join('');
      matrixHeader.appendChild(titleRow);

      // 2. Tạo Các Dòng Dữ Liệu
      tokens.forEach(token => {
        const rowKey = token.key;
        const row = document.createElement('tr');
        const label = `<strong>${token.symbol}</strong><div style="font-size:11px;color:#64748b;font-weight:normal;">${token.contract ? '(' + token.contract.slice(0, 6) + '...)' : 'Native'}</div>`;
        
        row.innerHTML = `<td class="token-cell">${label}</td>` + tokens.map(target => {
          const cell = matrix[rowKey] && matrix[rowKey][target.key] ? matrix[rowKey][target.key] : null;
          if (!cell || (!cell.out && !cell.in)) {
            return '<td class="empty-cell">-</td>';
          }
          const outText = cell.out ? `<span class="cell-out">-${formatNumber(cell.out)}</span>` : '';
          const inText = cell.in ? `<span class="cell-in">+${formatNumber(cell.in)}</span>` : '';
          return `<td>${outText}${inText}</td>`;
        }).join('');
        
        matrixBody.appendChild(row);
      });

      // 3. Render Badges Tổng Quan
      summaryBadges.style.display = 'flex';
      summaryBadges.innerHTML = `
        <div class="badge"><strong>Wallet</strong>${document.getElementById('wallet').value}</div>
        <div class="badge"><strong>Chain</strong>${document.getElementById('chain').value || 'ALL'}</div>
        <div class="badge"><strong>Total Tokens</strong>${tokens.length}</div>
      `;
    }

    async function fetchMatrix() {
      const wallet = document.getElementById('wallet').value.trim();
      const chain = document.getElementById('chain').value.trim();
      const from_date = document.getElementById('from_date').value;
      const to_date = document.getElementById('to_date').value;

      if (!wallet) {
        statusMessage.textContent = '❌ Vui lòng nhập Địa chỉ ví (Wallet Address)!';
        statusMessage.className = 'status-msg error';
        return;
      }

      // UI Loading state
      searchBtn.disabled = true;
      searchBtn.innerHTML = '⏳ Searching...';
      statusMessage.textContent = '⏳ Đang truy vấn ma trận dữ liệu từ Server...';
      statusMessage.className = 'status-msg info';

      try {
        const params = new URLSearchParams({ wallet, chain, from_date, to_date });
        const res = await fetch(`/api/pool-token-summary?${params.toString()}`);
        const result = await res.json();
        
        if (!res.ok || result.status !== 'success') {
          throw new Error(result.message || 'Lỗi hệ thống khi lấy dữ liệu!');
        }
        
        currentData = result.data;
        buildTable(currentData);
      } catch (err) {
        statusMessage.textContent = `❌ ${err.message}`;
        statusMessage.className = 'status-msg error';
      } finally {
        searchBtn.disabled = false;
        searchBtn.innerHTML = '🔍 Search Matrix';
      }
    }

    // Sự kiện Nút Search
    searchBtn.addEventListener('click', (e) => {
      e.preventDefault();
      fetchMatrix();
    });

    // Xuất file CSV
    exportBtn.addEventListener('click', () => {
      if (!currentData || !currentData.tokens) {
        alert('Không có dữ liệu để xuất file CSV!');
        return;
      }
      let csvContent = "data:text/csv;charset=utf-8,Token," + currentData.tokens.map(t => t.symbol).join(",") + "\n";
      currentData.tokens.forEach(r => {
        let rowStr = r.symbol;
        currentData.tokens.forEach(c => {
          const cell = currentData.matrix[r.key]?.[c.key];
          const val = cell ? `OUT:${cell.out}|IN:${cell.in}` : '0';
          rowStr += `,"${val}"`;
        });
        csvContent += rowStr + "\n";
      });

      const encodedUri = encodeURI(csvContent);
      const link = document.createElement("a");
      link.setAttribute("href", encodedUri);
      link.setAttribute("download", `matrix_${document.getElementById('wallet').value}.csv`);
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    });
  
