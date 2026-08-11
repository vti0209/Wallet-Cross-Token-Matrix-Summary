from decimal import Decimal, ROUND_HALF_UP, getcontext
from typing import Any, Dict, List, Tuple
from datetime import datetime

try:
    from db_config import get_connection
except ImportError:
    from db_config import get_connection

getcontext().prec = 28

# === DANH SACH STABLECOIN ===
STABLECOINS = {
    "USDT", "USDC", "DAI", "FDUSD", "PYUSD", "USDE", "USD1", "USDS", "USDP",
    "GUSD", "TUSD", "FRAX", "CRVUSD", "LUSD", "SUSD", "USDD", "USDG",
    "USD0", "USYC", "USAT", "USR",
    "EURC", "EURS", "EURT", "GYEN", "XSGD", "IDRT", "TRYB", "CADC", "BRZ",
    "PAXG", "XAUT"
}

# === DANH SACH WRAPPED TOKEN ===
WRAPPED_TOKENS = {
    "WETH", "WBTC", "CBBTC", "TBTC", "WBNB", "WSOL", "WAVAX", "WPOL",
    "WMATIC", "WFTM", "WSTETH", "WBETH", "WEETH", "OSETH",
    "MSTSOL", "JSOL", "BSOL", "BONKSOL",
    "USDC.E", "USDT.E", "ETH.E", "BTC.B"
}

# === DANH SACH TOKEN GOC BI AN ===
BASE_TOKENS_HIDDEN = {
    "ETH", "BTC", "BNB", "SOL", "AVAX", "MATIC", "POL", "FTM",
    "XRP", "LTC", "DOGE", "ADA", "STETH"
}

# === DANH SACH CONTRACT THEO CHAIN ===
STABLE_CONTRACTS = {
    # Base
    "0x833589fcd6edb6e08f4c7c32d4f71b54bda02913": "USDC",
    "0x50c5725949a6f0c72e6c4a641f24049a917db0cb": "DAI",
    "0x94b008aa00579c1307b0ef2c499ad98a8ce58e58": "USDT",
    # Ethereum
    "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48": "USDC",
    "0xdac17f958d2ee523a2206206994597c13d831ec7": "USDT",
    "0x6b175474e89094c44da98b954eedeac495271d0f": "DAI",
    # BSC
    "0x55d398326f99059ff775485246999027b3197955": "USDT",
    "0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d": "USDC",
    "0x1af3f329e8be154074d8769d1ffa4ee058b1dbc3": "DAI",
    # Arbitrum
    "0xaf88d065e77c8cc2239327c5edb3a432268e5831": "USDC",
    "0xfd086bc7cd5c481dcc9c85ebe478a1c0b69fcbb9": "USDT",
    # Polygon
    "0x2791bca1f2de4661ed88a30c99a7a9449aa84174": "USDC",
    "0xc2132d05d31c914a87c6611c10748aeb04b58e8f": "USDT",
    # Solana
    "epjfwdd5uzf6ybzjgk4ki9djbez3d8m": "USDC",
    "es9vmfrzscqj0qd9w9j2fkysf4yf": "USDT",
}

WRAPPED_CONTRACTS = {
    # Base
    "0x4200000000000000000000000000000000000006": "WETH",
    "0xc1cba3fcea344f92d9239c08c0568f6f2f0ee452": "WSTETH",
    "0x2ae3f1ec7f1f5012cfeab0185bfc7aa3cf0dec22": "CBTC",
    "0xbf927b841994731c573bdf09ceb0c6b0aa887cdd": "VELVET",
    # Ethereum
    "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2": "WETH",
    "0x2260fac5e5542a773aa44fbcfedf7c193bc2c599": "WBTC",
    "0x7f39c581f595b53c5cb19bd0b3f8da6c935e2ca0": "WSTETH",
    # BSC
    "0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c": "WBNB",
    "0x2170ed0880ac9a755fd29b2688956bd959f933f8": "WETH",
    # Arbitrum
    "0x82af49447d8a07e3bd95bd0d56f35241523fbab1": "WETH",
    "0x2f2a2543b76a4166549f7aab2e75bef0aefc5b0f": "WBTC",
    # Polygon
    "0x0d500b1d8e8ef31e21c99d1db9a6444d3adf1270": "WPOL",
    "0x7ceb23fd6bc0add59e62ac25578270cff1b9f619": "WETH",
    # Solana
    "so11111111111111111111111111111111111111112": "WSOL",
    "7vfctest5dzxbjh5huqkmvxvsnpu3mh3mdw": "MSTSOL",
}


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


def is_hidden_row_token(symbol: str, contract: str = '', chain: str = '') -> bool:
    """
    Kiem tra token co bi an hang hay khong
    AN TAT CA: stablecoin, wrapped, staking, bridged, chain native, ...
    """
    if not symbol:
        return True
    
    symbol_upper = symbol.upper()
    contract_lower = contract.lower() if contract else ''
    
    # === DANH SACH TOKEN CHAC CHAN BI AN ===
    HARDCODE_HIDDEN = {
        # Stablecoin
        "USDT", "USDC", "DAI", "FDUSD", "PYUSD", "USDE", "USD1", "USDS", "USDP",
        "GUSD", "TUSD", "FRAX", "CRVUSD", "LUSD", "SUSD", "USDD", "USDG",
        "USD0", "USYC", "USAT", "USR",
        "EURC", "EURS", "EURT", "GYEN", "XSGD", "IDRT", "TRYB", "CADC", "BRZ",
        "PAXG", "XAUT",
        # Wrapped token
        "WETH", "WBTC", "CBBTC", "TBTC", "WBNB", "WSOL", "WAVAX", "WPOL",
        "WMATIC", "WFTM", "WSTETH", "WBETH", "WEETH", "OSETH",
        "MSTSOL", "JSOL", "BSOL", "BONKSOL",
        "USDC.E", "USDT.E", "ETH.E", "BTC.B",
        # Chain native
        "ETH", "BTC", "BNB", "SOL", "AVAX", "MATIC", "POL", "FTM",
        "XRP", "LTC", "DOGE", "ADA", "STETH", "CAKE", "AERO", "ÚSDC", "U$DC", "EṬH" 
    }
    
    if symbol_upper in HARDCODE_HIDDEN:
        return True
    
    # === 1. CHECK CONTRACT ===
    if contract_lower in STABLE_CONTRACTS:
        return True
    if contract_lower in WRAPPED_CONTRACTS:
        return True
    
    # === 2. CHECK EXACT SYMBOL ===
    if symbol_upper in STABLECOINS:
        return True
    if symbol_upper in WRAPPED_TOKENS:
        return True
    
    # === 3. CHECK PREFIX - Wrapped token (W + token) ===
    if symbol_upper.startswith('W') and len(symbol_upper) >= 3:
        base = symbol_upper[1:]
        common_tokens = ['ETH', 'BTC', 'BNB', 'SOL', 'AVAX', 'FTM', 'XRP', 
                        'LTC', 'DOGE', 'ADA', 'MATIC', 'POL', 'STETH']
        if base in common_tokens or base in ['BETH', 'BBTC', 'XRP']:
            return True
        if base and base[0].isdigit():
            for token in common_tokens:
                if token in base:
                    return True
    
    # === 4. CHECK PREFIX - Staking token (ST + token) ===
    if symbol_upper.startswith('ST') and len(symbol_upper) >= 3:
        base = symbol_upper[2:]
        common_tokens = ['ETH', 'SOL', 'BTC', 'BNB', 'AVAX']
        if base in common_tokens:
            return True
    
    # === 5. CHECK SUFFIX - Bridged token (.E / .B) ===
    if symbol_upper.endswith('.E') or symbol_upper.endswith('.B'):
        return True
    
    # === 6. CHECK SUFFIX - ETH ===
    if symbol_upper.endswith('ETH'):
        return True
    
    # === 7. CHECK SUFFIX - BTC ===
    if symbol_upper.endswith('BTC'):
        return True
    
    # === 8. CHECK SUFFIX - SOL ===
    if symbol_upper.endswith('SOL'):
        return True
    
    # === 9. CHECK SUFFIX - BNB ===
    if symbol_upper.endswith('BNB'):
        return True
    
    # === 10. CHECK SUFFIX - AVAX ===
    if symbol_upper.endswith('AVAX'):
        return True
    
    # === 11. CHECK PATTERN - Contains USD ===
    if 'USD' in symbol_upper:
        return True
    
    # === 12. CHECK PATTERN - Contains DAI ===
    if 'DAI' in symbol_upper:
        return True
    
    # === 13. CHECK SPECIAL CASES ===
    SPECIAL_HIDDEN = {
        "CBBTC", "TBTC", "LBTC", "BTCB", "BBTC",
        "OSETH", "RETH", "CBETH", "MSTSOL", "JSOL", "BSOL", "BONKSOL"
    }
    if symbol_upper in SPECIAL_HIDDEN:
        return True
    
    # === 14. CHECK CONTAINS "WRAPPED" ===
    if 'WRAPPED' in symbol_upper:
        return True
    
    # === 15. CHECK BASE TOKENS ===
    if symbol_upper in BASE_TOKENS_HIDDEN:
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
                'is_hidden': is_hidden_row_token(s, c, chain)
            })
        return tokens
    finally:
        cursor.close()
        conn.close()


def get_row_tokens(all_tokens: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Loc token lam HANG: chi lay token khong bi an"""
    return [t for t in all_tokens if not t.get('is_hidden', False)]


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
    - HANG: Chi cac token binh thuong (khong bi an) VA CO IT NHAT 1 MOI QUAN HE
    """
    if not to_date:
        to_date = datetime.now().strftime('%Y-%m-%d')
    
    all_tokens = get_all_tokens_from_db(wallet_address, chain, from_date, to_date)
    
    headers = [
        {'symbol': t['symbol'], 'contract': t['contract'], 'key': t['key']} 
        for t in all_tokens
    ]
    
    if not all_tokens:
        return {'headers': [], 'rows': []}
    
    row_tokens_temp = get_row_tokens(all_tokens)
    
    if not row_tokens_temp:
        return {'headers': headers, 'rows': []}
    
    # Xay dung ma tran tam thoi de kiem tra moi quan he
    matrix = {}
    valid_row_keys = set()
    
    for row_token in row_tokens_temp:
        row_key = row_token['key']
        symbol = row_token['symbol']
        contract = row_token['contract']
        
        summary = get_token_summary_from_db(wallet_address, chain, from_date, to_date, symbol, contract)
        
        row_cells = {}
        has_relation = False
        
        for col_token in all_tokens:
            col_key = col_token['key']
            if col_key in summary:
                row_cells[col_key] = {
                    'sent': summary[col_key]['sent'],
                    'received': summary[col_key]['received'],
                    'touched': True
                }
                has_relation = True
            else:
                row_cells[col_key] = {
                    'sent': 0.0,
                    'received': 0.0,
                    'touched': False
                }
        
        # Chi luu row neu co it nhat 1 moi quan he
        if has_relation:
            matrix[row_key] = row_cells
            valid_row_keys.add(row_key)
    
    # Loc lai row_tokens chi nhung token co moi quan he
    row_tokens = [t for t in row_tokens_temp if t['key'] in valid_row_keys]
    
    # Rows - chi cac token co moi quan he
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