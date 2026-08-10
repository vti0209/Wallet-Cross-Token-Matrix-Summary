from decimal import Decimal, ROUND_HALF_UP, getcontext
from typing import Any, Dict, List, Tuple

try:
    from db_config import get_connection
except ImportError:
    from db_config import get_connection

getcontext().prec = 28


def _to_decimal(val: Any) -> Decimal:
    if isinstance(val, Decimal):
        return val
    try:
        if val is None or str(val).strip() == '':
            return Decimal('0')
        return Decimal(str(val))
    except Exception:
        return Decimal('0')


def _format_decimal(d: Decimal) -> float:
    q = d.quantize(Decimal('0.00001'), rounding=ROUND_HALF_UP)
    return float(q)


def normalize_token(symbol: str, contract_address: str) -> Tuple[str, str, str]:
    """Gộp Native SOL / SOL Contract về 1 Key chuẩn"""
    s = (symbol or "").strip().upper()
    c = (contract_address or "").strip().lower()

    if s == 'SOL' or c in ['', 'so11111111111111111111111111111111111111112']:
        s = 'SOL'
        c = 'so11111111111111111111111111111111111111112'

    key = f"{s}|{c}"
    return s, c, key


def get_all_tokens_from_db(wallet_address: str, chain: str, from_date: str, to_date: str) -> List[Dict[str, str]]:
    """
    Lấy tất cả token có giao dịch trong khoảng thời gian
    """
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    
    query = """
        SELECT DISTINCT
            UPPER(TRIM(COALESCE(d.symbol, ''))) AS symbol,
            LOWER(TRIM(COALESCE(d.contract, ''))) AS contract
        FROM transaction_history_v2 h
        INNER JOIN transaction_detail_v2 d ON d.hash = h.hash
        WHERE LOWER(h.wallet) = LOWER(%s)
          AND (%s = '' OR LOWER(h.chain) = LOWER(%s))
          AND h.date_time >= %s
          AND h.date_time < DATE_ADD(%s, INTERVAL 1 DAY)
          AND d.symbol IS NOT NULL
          AND TRIM(d.symbol) != ''
    """
    
    try:
        cursor.execute(query, [wallet_address, chain, chain, from_date, to_date])
        rows = cursor.fetchall()
        
        tokens = []
        for r in rows:
            s = r['symbol'] or 'UNKNOWN'
            c = r['contract'] or ''
            key = f"{s}|{c}"
            tokens.append({
                'symbol': s,
                'contract': c,
                'key': key
            })
        return tokens
    finally:
        cursor.close()
        conn.close()


def get_token_summary_from_db(wallet_address: str, chain: str, from_date: str, to_date: str, symbol: str, contract: str = '') -> Dict[str, Dict[str, float]]:
    """
    Lấy Token Transfer Summary cho 1 token cụ thể từ DB
    Sử dụng truy vấn CHUẨN giống như trang Transaction History
    """
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    
    # Truy vấn CHUẨN từ Transaction History
    query = """
        WITH selected_transactions AS (
            SELECT DISTINCT
                h.hash,
                h.chain,
                COALESCE(h.token_id, '') AS nft_token_id
            FROM transaction_history_v2 AS h
            WHERE LOWER(h.wallet) = LOWER(%s)
              AND (%s = '' OR h.chain = %s)
              AND h.date_time >= %s
              AND h.date_time < DATE_ADD(%s, INTERVAL 1 DAY)
        ),
        normalized_details AS (
            SELECT
                st.hash,
                st.chain,
                LOWER(TRIM(COALESCE(d.contract, ''))) AS contract,
                UPPER(TRIM(COALESCE(d.symbol, ''))) AS symbol,
                LOWER(COALESCE(d.from_address, '')) AS from_address,
                LOWER(COALESCE(d.to_address, '')) AS to_address,
                CAST(NULLIF(TRIM(d.amount), '') AS DECIMAL(65, 30)) AS amount
            FROM selected_transactions AS st
            INNER JOIN transaction_detail_v2 AS d ON d.hash = st.hash
        ),
        wallet_transfers AS (
            SELECT *
            FROM normalized_details
            WHERE CASE
                WHEN from_address = LOWER(%s) THEN amount < 0
                WHEN to_address = LOWER(%s) THEN amount > 0
                ELSE amount > 0
            END
        ),
        direct_token_transactions AS (
            SELECT DISTINCT wt.hash, wt.chain
            FROM wallet_transfers AS wt
            WHERE TRIM(COALESCE(%s, '')) <> ''
              AND wt.symbol = UPPER(TRIM(%s))
              AND (TRIM(COALESCE(%s, '')) = '' OR wt.contract = LOWER(TRIM(%s)))
        ),
        related_nft_ids AS (
            SELECT DISTINCT st.chain, st.nft_token_id
            FROM direct_token_transactions AS dt
            INNER JOIN selected_transactions AS st ON st.hash = dt.hash AND st.chain = dt.chain
            WHERE st.nft_token_id <> ''
        ),
        selected_hashes AS (
            SELECT st.hash, st.chain
            FROM selected_transactions AS st
            WHERE TRIM(COALESCE(%s, '')) = ''
            UNION
            SELECT dt.hash, dt.chain
            FROM direct_token_transactions AS dt
            UNION
            SELECT st.hash, st.chain
            FROM selected_transactions AS st
            WHERE TRIM(COALESCE(%s, '')) <> ''
              AND st.nft_token_id <> ''
              AND LOCATE(LOWER(TRIM(%s)), LOWER(st.nft_token_id)) > 0
            UNION
            SELECT st.hash, st.chain
            FROM related_nft_ids AS rn
            INNER JOIN selected_transactions AS st
                ON st.chain = rn.chain AND BINARY st.nft_token_id = BINARY rn.nft_token_id
        )
        SELECT
            wt.symbol,
            LOWER(TRIM(COALESCE(wt.contract, ''))) AS contract,
            SUM(CASE WHEN wt.amount < 0 THEN wt.amount ELSE 0 END) AS sent,
            SUM(CASE WHEN wt.amount >= 0 THEN wt.amount ELSE 0 END) AS received,
            SUM(wt.amount) AS total
        FROM selected_hashes AS sh
        INNER JOIN wallet_transfers AS wt ON wt.hash = sh.hash AND wt.chain = sh.chain
        GROUP BY wt.symbol, wt.contract
    """
    
    try:
        cursor.execute(query, [
            wallet_address, chain, chain, from_date, to_date,  # selected_transactions
            wallet_address, wallet_address,                    # wallet_transfers
            symbol, symbol, contract, contract,               # direct_token_transactions
            symbol,                                           # selected_hashes - empty check
            symbol, symbol                                    # selected_hashes - nft filter
        ])
        rows = cursor.fetchall()
        
        result = {}
        for r in rows:
            sym = r['symbol'] or 'UNKNOWN'
            con = r['contract'] or ''
            key = f"{sym}|{con}"
            sent = _to_decimal(r['sent'] or 0)
            received = _to_decimal(r['received'] or 0)
            result[key] = {
                'sent': _format_decimal(sent),
                'received': _format_decimal(received),
                'total': _format_decimal(sent + received)
            }
        
        return result
    finally:
        cursor.close()
        conn.close()


def generate_cross_token_matrix(wallet_address: str, chain: str, from_date: str, to_date: str) -> Dict[str, Any]:
    """
    Tạo ma trận cross-token
    """
    # 1. Lấy danh sách token
    tokens = get_all_tokens_from_db(wallet_address, chain, from_date, to_date)
    
    if not tokens:
        return {'headers': [], 'rows': []}
    
    token_keys = [t['key'] for t in tokens]
    
    # 2. Với mỗi token, lấy summary
    matrix = {}
    for token in tokens:
        row_key = token['key']
        symbol = token['symbol']
        contract = token['contract']
        
        # Lấy summary cho token này
        summary = get_token_summary_from_db(wallet_address, chain, from_date, to_date, symbol, contract)
        
        # Xây dựng row cells
        row_cells = {}
        for col_token in tokens:
            col_key = col_token['key']
            if col_key in summary:
                row_cells[col_key] = {
                    'sent': summary[col_key]['sent'],
                    'received': summary[col_key]['received'],
                    'touched': True
                }
            else:
                row_cells[col_key] = {
                    'sent': 0.0,
                    'received': 0.0,
                    'touched': False
                }
        
        matrix[row_key] = row_cells
    
    # 3. Định dạng kết quả
    headers = [
        {'symbol': t['symbol'], 'contract': t['contract'], 'key': t['key']} 
        for t in tokens
    ]
    
    rows = []
    for r_key in token_keys:
        token_info = next((t for t in tokens if t['key'] == r_key), None)
        if token_info:
            rows.append({
                'row_token': {
                    'symbol': token_info['symbol'],
                    'contract': token_info['contract'],
                    'key': r_key
                },
                'cells': matrix[r_key]
            })
    
    return {'headers': headers, 'rows': rows}