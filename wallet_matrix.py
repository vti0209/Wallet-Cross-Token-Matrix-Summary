from decimal import Decimal, ROUND_HALF_UP, getcontext
from typing import Any, Dict, List, Tuple

# Lưu ý: Sửa thành 'from db import get_connection' nếu file DB của ông tên là db.py
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


def get_transactions_from_db(wallet_address: str, chain: str, from_date: str, to_date: str) -> List[Dict[str, Any]]:
    """
    TRUY VẤN CHUẨN THEO ĐÚNG SQL V2 CỦA MENTOR:
    - Join transaction_history_v2 và transaction_detail_v2
    - Tính số âm/dương dựa vào from_address/to_address so với ví
    """
    wallet_address = (wallet_address or "").strip()
    chain = (chain or "").strip()
    from_date = (from_date or "").strip()
    to_date = (to_date or "").strip()

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    query_parts = [
        """
        SELECT 
            h.hash,
            LOWER(TRIM(COALESCE(d.contract, ''))) AS contract,
            UPPER(TRIM(COALESCE(d.symbol, ''))) AS symbol,
            LOWER(COALESCE(d.from_address, '')) AS from_address,
            LOWER(COALESCE(d.to_address, '')) AS to_address,
            CAST(NULLIF(TRIM(d.amount), '') AS DECIMAL(65, 30)) AS raw_amount
        FROM transaction_history_v2 AS h
        INNER JOIN transaction_detail_v2 AS d ON d.hash = h.hash
        WHERE LOWER(h.wallet) = LOWER(%s)
          AND (%s = '' OR LOWER(h.chain) = LOWER(%s))
        """,
    ]
    params: List[Any] = [wallet_address, chain, chain]

    if from_date:
        query_parts.append(" AND h.date_time >= %s")
        params.append(from_date)

    if to_date:
        query_parts.append(" AND h.date_time < DATE_ADD(%s, INTERVAL 1 DAY)")
        params.append(to_date)

    query = "".join(query_parts)

    try:
        cursor.execute(query, params)
        rows = cursor.fetchall()

        wallet_lower = wallet_address.strip().lower()
        tx_map = {}

        for r in rows:
            h = r['hash']
            if h not in tx_map:
                tx_map[h] = {'hash': h, 'details': []}

            raw_amt = _to_decimal(r.get('raw_amount', 0))
            from_addr = str(r.get('from_address', '')).lower()
            to_addr = str(r.get('to_address', '')).lower()

            # Logic phân định IN/OUT chuẩn từ SQL của Mentor
            if from_addr == wallet_lower:
                final_amt = -abs(raw_amt)  # Wallet gửi đi -> Số ÂM
            elif to_addr == wallet_lower:
                final_amt = abs(raw_amt)   # Wallet nhận về -> Số DƯƠNG
            else:
                final_amt = raw_amt

            tx_map[h]['details'].append({
                'symbol': r.get('symbol'),
                'contract_address': r.get('contract'),
                'amount': final_amt
            })

        return list(tx_map.values())
    finally:
        cursor.close()
        conn.close()


def generate_cross_token_matrix(transactions: List[Dict[str, Any]]) -> Dict[str, Any]:
    """
    Tính toán ma trận dòng tiền chéo giữa các Token.

    Ý nghĩa ô matrix[row][col]:
        Trong các giao dịch (hash) có mặt CẢ token `row` LẪN token `col`,
        token `col` đã có tổng out/in bao nhiêu.

    'touched' = True nghĩa là cặp (row, col) từng cùng xuất hiện trong ít
    nhất 1 giao dịch thật (kể cả khi tổng ra đúng bằng 0). Chỉ khi
    'touched' = False (DB không hề có tx nào chứa cặp này) mới coi là
    "không có quan hệ" -> phía hiển thị nên show dấu '-'.
    """
    tokens_map: Dict[str, Tuple[str, str]] = {}

    for tx in transactions:
        for d in tx.get('details', []):
            s, c, key = normalize_token(d.get('symbol'), d.get('contract_address'))
            if s and key not in tokens_map:
                tokens_map[key] = (s, c)

    if not tokens_map:
        return {'headers': [], 'rows': []}

    token_keys = list(tokens_map.keys())
    zero = Decimal('0')

    matrix = {
        r: {c: {'out': zero, 'in': zero, 'touched': False} for c in token_keys}
        for r in token_keys
    }

    for tx in transactions:
        details = tx.get('details', [])
        if not details:
            continue

        tx_tokens: Dict[str, Decimal] = {}
        for d in details:
            s, c, key = normalize_token(d.get('symbol'), d.get('contract_address'))
            if not s:
                continue
            amt = _to_decimal(d.get('amount', '0'))
            tx_tokens[key] = tx_tokens.get(key, zero) + amt

        tx_keys = list(tx_tokens.keys())
        if not tx_keys:
            continue

        # Với MỌI cặp (row, col) token cùng xuất hiện trong tx này (kể cả row == col),
        # cộng dồn in/out của token "col" vào ô [row][col], và đánh dấu touched = True.
        for row_key in tx_keys:
            for col_key in tx_keys:
                col_amt = tx_tokens[col_key]
                cell = matrix[row_key][col_key]

                cell['touched'] = True  # có data thật, dù giá trị = 0 vẫn ghi nhận quan hệ

                if col_amt < zero:
                    cell['out'] += abs(col_amt)
                else:
                    # bao gồm cả col_amt == 0 -> cộng 0 không đổi giá trị số,
                    # nhưng 'touched' đã đủ để đánh dấu quan hệ tồn tại
                    cell['in'] += abs(col_amt)

    headers = [{'symbol': tokens_map[k][0], 'contract': tokens_map[k][1], 'key': k} for k in token_keys]
    rows = []

    for r_key in token_keys:
        row_cells = {}
        for c_key in token_keys:
            cell = matrix[r_key][c_key]
            row_cells[c_key] = {
                'out': _format_decimal(cell['out']),
                'in': _format_decimal(cell['in']),
                'touched': cell['touched'],
            }
        rows.append({
            'row_token': {'symbol': tokens_map[r_key][0], 'contract': tokens_map[r_key][1], 'key': r_key},
            'cells': row_cells
        })

    return {'headers': headers, 'rows': rows}