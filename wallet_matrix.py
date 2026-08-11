from decimal import Decimal, ROUND_HALF_UP, getcontext
from typing import Any, Dict, List, Tuple
from datetime import datetime

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
    s = (symbol or "").strip().upper()
    c = (contract_address or "").strip().lower()

    if s == 'SOL' or c in ['', 'so11111111111111111111111111111111111111112']:
        s = 'SOL'
        c = 'so11111111111111111111111111111111111111112'

    key = f"{s}|{c}"
    return s, c, key


def is_stablecoin(symbol: str) -> bool:
    """Kiem tra token co phai stablecoin khong dua tren symbol"""
    symbol_upper = symbol.upper()
    stable_keywords = ['USD', 'DAI', 'BUSD', 'TUSD', 'USDP', 'GUSD', 'UST', 'FRAX', 'LUSD', 'MIM', 'FEI', 'ALUSD']
    for kw in stable_keywords:
        if kw in symbol_upper:
            return True
    return False


def is_wrapped_token(symbol: str) -> bool:
    """Kiem tra token co phai wrapped token khong"""
    symbol_upper = symbol.upper()
    if symbol_upper.startswith('W') and len(symbol_upper) >= 3:
        base = symbol_upper[1:]
        common_tokens = ['ETH', 'BTC', 'BNB', 'MATIC', 'AVAX', 'FTM', 'XRP', 'LTC', 'DOGE', 'ADA', 'SOL', 'STETH']
        if base in common_tokens or base in ['BETH', 'BBTC', 'XRP']:
            return True
    return False


def is_stable_wrapped(symbol: str, contract: str = '') -> bool:
    """Kiem tra token co phai stablecoin hoac wrapped token khong"""
    if not symbol:
        return False
    
    symbol_upper = symbol.upper()
    
    # 1. Kiem tra stablecoin
    if is_stablecoin(symbol):
        return True
    
    # 2. Kiem tra wrapped token
    if is_wrapped_token(symbol):
        return True
    
    # 3. Kiem tra contract cua cac token pho bien (fallback)
    contract_lower = contract.lower() if contract else ''
    wrapped_contracts = {
        '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2',  # WETH on ETH
        '0x2260fac5e5542a773aa44fbcfedf7c193bc2c599',  # WBTC on ETH
        '0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c',  # WBNB on BSC
        '0x0d500b1d8e8ef31e21c99d1db9a6444d3adf1270',  # WMATIC on POL
        '0x49d5c2bdffac6ce2bfdb6640f4f80f226bc10bab',  # WETH on ARB
        '0x82af49447d8a07e3bd95bd0d56f35241523fbab1',  # WETH on ARB
        '0x4200000000000000000000000000000000000006',  # WETH on BAS
    }
    if contract_lower in wrapped_contracts:
        return True
    
    stable_contracts = {
        '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48',  # USDC on ETH
        '0xdac17f958d2ee523a2206206994597c13d831ec7',  # USDT on ETH
        '0x6b175474e89094c44da98b954eedeac495271d0f',  # DAI on ETH
        '0x833589fcd6edb6e08f4c7c32d4f71b54bda02913',  # USDC on BAS
        '0x55d398326f99059ff775485246999027b3197955',  # USDT on BSC
        '0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d',  # USDC on BSC
    }
    if contract_lower in stable_contracts:
        return True
    
    return False


def get_all_tokens_from_db(wallet_address: str, chain: str, from_date: str, to_date: str) -> List[Dict[str, Any]]:
    """Lay tat ca token xuat hien trong giao dich (dung cho COT)"""
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    
    if not to_date:
        to_date = datetime.now().strftime('%Y-%m-%d')
    
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
                'key': key,
                'is_stable_wrapped': is_stable_wrapped(s, c)
            })
        return tokens
    finally:
        cursor.close()
        conn.close()


def get_row_tokens(all_tokens: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Loc token lam HANG: chi lay token binh thuong (khong phai stablecoin/wrapped)"""
    return [t for t in all_tokens if not t.get('is_stable_wrapped', False)]


def get_token_summary_from_db(wallet_address: str, chain: str, from_date: str, to_date: str, symbol: str, contract: str = '') -> Dict[str, Dict[str, float]]:
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    
    if not to_date:
        to_date = datetime.now().strftime('%Y-%m-%d')
    
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
            wallet_address, chain, chain, from_date, to_date,
            wallet_address, wallet_address,
            symbol, symbol, contract, contract,
            symbol,
            symbol, symbol
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
    Tao ma tran cross-token
    
    - COT: Tat ca token xuat hien trong giao dich (bao gom ca stablecoin/wrapped)
    - HANG: Chi cac token binh thuong (khong phai stablecoin/wrapped)
    """
    if not to_date:
        to_date = datetime.now().strftime('%Y-%m-%d')
    
    # Lay tat ca token (cho COT)
    all_tokens = get_all_tokens_from_db(wallet_address, chain, from_date, to_date)
    
    # Lay token lam HANG (chi token binh thuong)
    row_tokens = get_row_tokens(all_tokens)
    
    if not all_tokens or not row_tokens:
        return {'headers': [], 'rows': []}
    
    # Xay dung ma tran
    matrix = {}
    for row_token in row_tokens:
        row_key = row_token['key']
        symbol = row_token['symbol']
        contract = row_token['contract']
        
        # Lay summary cho token nay
        summary = get_token_summary_from_db(wallet_address, chain, from_date, to_date, symbol, contract)
        
        # Xay dung row cells cho TAT CA token
        row_cells = {}
        for col_token in all_tokens:
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
    
    # Headers (cot) - tat ca token
    headers = [
        {'symbol': t['symbol'], 'contract': t['contract'], 'key': t['key']} 
        for t in all_tokens
    ]
    
    # Rows - chi cac token binh thuong
    rows = []
    for r_token in row_tokens:
        r_key = r_token['key']
        rows.append({
            'row_token': {
                'symbol': r_token['symbol'],
                'contract': r_token['contract'],
                'key': r_key
            },
            'cells': matrix.get(r_key, {})
        })
    
    return {'headers': headers, 'rows': rows}