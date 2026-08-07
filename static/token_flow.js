document.addEventListener("DOMContentLoaded", () => {
  const searchBtn = document.getElementById("searchBtn");
  const exportCsvBtn = document.getElementById("exportCsvBtn");
  const walletInput = document.getElementById("walletInput");
  const chainSelect = document.getElementById("chainSelect");
  const fromDateInput = document.getElementById("fromDateInput");
  const toDateInput = document.getElementById("toDateInput");
  
  const statusContainer = document.getElementById("statusContainer");
  const summaryMetrics = document.getElementById("summaryMetrics");
  const tableHead = document.getElementById("tableHead");
  const tableBody = document.getElementById("tableBody");
  const summaryTable = document.getElementById("summaryTable");
  const emptyState = document.getElementById("emptyState");
  const loadingSpinner = document.getElementById("loadingSpinner");

  let currentResponseData = null;

  function showStatus(message, isError = false) {
    statusContainer.textContent = message;
    statusContainer.className = isError ? "status-box error" : "status-box info";
    statusContainer.style.display = "block";
  }

  function hideStatus() {
    statusContainer.style.display = "none";
  }

  function formatNum(val) {
    if (val === null || val === undefined || val === "") {
      return "0";
    }
    const num = parseFloat(val);
    if (isNaN(num)) return "0";
    if (num === 0) return "0";
    if (Math.abs(num) < 0.000001) return num.toExponential(4);
    return num.toLocaleString(undefined, { maximumFractionDigits: 8 });
  }

  async function performSearch() {
    const wallet = walletInput.value.trim();
    const chain = chainSelect.value.trim();
    const fromDate = fromDateInput.value.trim();
    const toDate = toDateInput.value.trim();

    if (!wallet) {
      showStatus("Please enter a wallet address.", true);
      walletInput.focus();
      return;
    }
    if (!chain) {
      showStatus("Please select or enter a chain.", true);
      chainSelect.focus();
      return;
    }
    if (!fromDate) {
      showStatus("From Date is required.", true);
      fromDateInput.focus();
      return;
    }

    hideStatus();
    loadingSpinner.style.display = "flex";
    summaryTable.style.display = "none";
    emptyState.style.display = "none";
    exportCsvBtn.disabled = true;

    try {
      const response = await fetch("/api/pool-token-summary", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          wallet: wallet,
          chain: chain,
          from_date: fromDate,
          to_date: toDate
        })
      });

      const json = await response.json();
      loadingSpinner.style.display = "none";

      if (json.status !== "success") {
        showStatus(json.message || "Failed to fetch pool token summary data.", true);
        return;
      }

      currentResponseData = json.data;
      renderTable(json.data, json.query);

    } catch (err) {
      loadingSpinner.style.display = "none";
      showStatus("Network or server error: " + err.message, true);
    }
  }

  function renderTable(data, query) {
    tableHead.innerHTML = "";
    tableBody.innerHTML = "";

    const flow = data.flow || [];
    const tokens = data.tokens || [];
    const matrix = data.matrix || {};

    if (!flow.length || !tokens.length) {
      summaryMetrics.style.display = "none";
      emptyState.style.display = "block";
      exportCsvBtn.disabled = true;
      return;
    }

    summaryMetrics.innerHTML = `
      <div class="metric-card"><strong>Wallet:</strong> <span class="mono">${query.wallet}</span></div>
      <div class="metric-card"><strong>Chain:</strong> <span>${query.chain}</span></div>
      <div class="metric-card"><strong>From:</strong> <span>${query.from_date}</span></div>
      <div class="metric-card"><strong>To:</strong> <span>${query.to_date}</span></div>
      <div class="metric-card"><strong>Main Tokens:</strong> <span>${flow.length}</span></div>
      <div class="metric-card"><strong>Total Columns:</strong> <span>${tokens.length}</span></div>
    `;
    summaryMetrics.style.display = "flex";

    // 1. Single Header Row
    const trHead = document.createElement("tr");
    
    // Column 1: Token
    const thToken = document.createElement("th");
    thToken.textContent = "Token";
    thToken.className = "sticky-col first-col";
    trHead.appendChild(thToken);

    // Column 2..N: Counter Token Symbols
    tokens.forEach(tok => {
      const thCol = document.createElement("th");
      thCol.className = "token-header-col";
      const symbolStr = tok.symbol || tok.label;
      const contractStr = tok.contract ? `(${tok.contract.slice(0, 6)}...${tok.contract.slice(-4)})` : "";
      thCol.innerHTML = `<div class="head-symbol">${symbolStr}</div><div class="head-contract">${contractStr}</div>`;
      trHead.appendChild(thCol);
    });
    tableHead.appendChild(trHead);

    // 2. Build Body Rows (One row per Main Token)
    flow.forEach(rowItem => {
      const tr = document.createElement("tr");
      const mainKey = rowItem.key;
      const matrixRow = matrix[mainKey] || {};

      // Column 1 (Sticky): Main Token Symbol & (Contract Address)
      const tdMainToken = document.createElement("td");
      tdMainToken.className = "sticky-col first-col token-name-cell";
      const contractDisplay = rowItem.contract ? `(${rowItem.contract.slice(0, 6)}...${rowItem.contract.slice(-4)})` : "";
      tdMainToken.innerHTML = `
        <div class="token-symbol">${rowItem.symbol}</div>
        <div class="token-contract">${contractDisplay}</div>
      `;
      tr.appendChild(tdMainToken);

      // Remaining Columns: Counter Token cells
      tokens.forEach(colToken => {
        const colKey = colToken.key;
        const cellData = matrixRow[colKey] || { out: "0", in: "0", has_relation: false };

        const tdCell = document.createElement("td");
        tdCell.className = "matrix-cell";

        if (!cellData.has_relation) {
          // Trống hoàn toàn nếu KHÔNG có giao dịch liên quan
          tdCell.innerHTML = "";
        } else {
          // CÓ giao dịch liên quan -> Hiển thị cả Dòng 1 RED (OUT) và Dòng 2 GREEN (IN), kể cả khi là 0
          const outNum = parseFloat(cellData.out || "0");
          const inNum = parseFloat(cellData.in || "0");

          const formattedOut = formatNum(cellData.out);
          const formattedIn = formatNum(cellData.in);

          const outText = outNum > 0 ? `-${formattedOut}` : "0";
          const inText = formattedIn;

          tdCell.innerHTML = `
            <div class="val-out ${outNum === 0 ? 'zero-val' : ''}">${outText}</div>
            <div class="val-in ${inNum === 0 ? 'zero-val' : ''}">${inText}</div>
          `;
        }

        tr.appendChild(tdCell);
      });

      tableBody.appendChild(tr);
    });

    summaryTable.style.display = "table";
    emptyState.style.display = "none";
    exportCsvBtn.disabled = false;
  }

  function exportCSV() {
    if (!currentResponseData || !currentResponseData.flow || !currentResponseData.flow.length) {
      showStatus("No data available to export.", true);
      return;
    }

    const flow = currentResponseData.flow;
    const tokens = currentResponseData.tokens;
    const matrix = currentResponseData.matrix;

    const headers = ["Token", "Contract"];
    tokens.forEach(tok => {
      headers.push(`${tok.symbol} OUT`);
      headers.push(`${tok.symbol} IN`);
    });

    const csvRows = [];
    csvRows.push(headers.map(h => `"${h.replace(/"/g, '""')}"`).join(","));

    flow.forEach(rowItem => {
      const mainKey = rowItem.key;
      const matrixRow = matrix[mainKey] || {};
      const rowCells = [
        `"${(rowItem.symbol || "").replace(/"/g, '""')}"`,
        `"${(rowItem.contract || "").replace(/"/g, '""')}"`
      ];

      tokens.forEach(colToken => {
        const colKey = colToken.key;
        const cellData = matrixRow[colKey] || { out: "0", in: "0" };
        const outVal = parseFloat(cellData.out) > 0 ? `-${cellData.out}` : "0";
        const inVal = cellData.in || "0";
        rowCells.push(`"${outVal}"`);
        rowCells.push(`"${inVal}"`);
      });

      csvRows.push(rowCells.join(","));
    });

    const csvContent = "\uFEFF" + csvRows.join("\n");
    const blob = new Blob([csvContent], { type: "text/csv;charset=utf-8;" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `pool_token_summary_${walletInput.value.trim()}_${chainSelect.value.trim()}.csv`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
  }

  searchBtn.addEventListener("click", performSearch);
  exportCsvBtn.addEventListener("click", exportCSV);
});
