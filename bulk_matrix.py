"""
Tinh toan ma tran cross-token bang cach lay du lieu giao dich 1 lan roi xu ly
bang Python, thay vi query rieng cho tung token (giam thoi gian tu ~4 phut
xuong con vai giay voi vi co nhieu token).
"""

from decimal import Decimal, ROUND_HALF_UP, getcontext
from typing import Any, Dict, List
from datetime import datetime

import unicodedata

from db_config import get_connection

getcontext().prec = 28


def _collation_key(symbol: str) -> str:
    """Bo cac ky tu dinh dang/dau vo hinh (Cf, Mn, Me) khoi symbol - token scam
    hay chen loai ky tu nay de gia mao ten token that (USDT, USDC...).
    Tai hien hanh vi so sanh chuoi cua MySQL collation utf8mb4_unicode_ci."""
    if not symbol:
        return ''
    return ''.join(
        ch for ch in symbol
        if unicodedata.category(ch) not in ('Cf', 'Mn', 'Me')
    )


def _format_decimal(d: Decimal) -> float:
    q = d.quantize(Decimal('0.00001'), rounding=ROUND_HALF_UP)
    return float(q)


def get_bulk_wallet_transfers(wallet_address: str, chain: str, from_date: str, to_date: str) -> List[Dict[str, Any]]:
    """
    Lay TOAN BO chi tiet giao dich cua vi trong khoang ngay, 1 lan duy nhat.
    Tuong duong voi selected_transactions + normalized_details trong ban SQL goc,
    nhung KHONG loc theo tung token - lay het.
    """
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    if not to_date:
        to_date = datetime.now().strftime('%Y-%m-%d')

    query = """
        SELECT
            h.hash,
            h.chain,
            COALESCE(h.token_id, '') AS nft_token_id,
            LOWER(TRIM(COALESCE(CONVERT(d.contract USING utf8mb4), ''))) AS contract,
            UPPER(TRIM(COALESCE(CONVERT(d.symbol USING utf8mb4), ''))) AS symbol,
            LOWER(COALESCE(d.from_address, '')) AS from_address,
            LOWER(COALESCE(d.to_address, '')) AS to_address,
            CAST(NULLIF(TRIM(d.amount), '') AS DECIMAL(65, 30)) AS amount
        FROM transaction_history_v2 AS h
        INNER JOIN transaction_detail_v2 AS d ON d.hash = h.hash
        WHERE LOWER(h.wallet) = LOWER(%s)
          AND (%s = '' OR h.chain = %s)
          AND h.date_time >= %s
          AND h.date_time < DATE_ADD(%s, INTERVAL 1 DAY)
    """
    try:
        cursor.execute(query, [wallet_address, chain, chain, from_date, to_date])
        return cursor.fetchall()
    except Exception as e:
        print(f"Error in get_bulk_wallet_transfers: {e}")
        return []
    finally:
        cursor.close()
        conn.close()


class BulkMatrixEngine:
    """
    Nhan toan bo giao dich cua vi (tu get_bulk_wallet_transfers), tinh summary
    sent/received cho tung token ma khong can query them DB.
    Logic tuong duong voi ham SQL goc get_token_summary_from_db.
    """

    def __init__(self, rows: List[Dict[str, Any]], wallet_address: str):
        wallet_lower = (wallet_address or '').strip().lower()

        # hash -> (chain, nft_token_id)  [lay tu dong dau tien gap cua hash do]
        self.selected_tx: Dict[str, Any] = {}
        # hash -> list of detail dict {symbol, contract, amount(Decimal)} da qua loc CASE
        self.wallet_transfers_by_hash: Dict[str, List[Dict[str, Any]]] = {}
        # (symbol, contract) -> set(hash) : dung khi row token CO contract cu the
        self.hash_by_symbol_contract: Dict[Any, set] = {}
        # symbol -> set(hash) : dung khi row token KHONG co contract (contract == '')
        self.hash_by_symbol_any_contract: Dict[str, set] = {}
        # danh sach (hash, chain, nft_id_lower) chi cho hash co nft_token_id != ''
        self.nft_hashes: List[Any] = []

        for r in rows:
            h = r['hash']
            chain_v = r['chain']
            nft_id = r['nft_token_id'] or ''

            if h not in self.selected_tx:
                self.selected_tx[h] = (chain_v, nft_id)
                if nft_id != '':
                    self.nft_hashes.append((h, chain_v, nft_id, nft_id.lower()))

            amount = r['amount']
            if amount is None:
                continue
            amount = Decimal(str(amount))

            from_addr = r['from_address'] or ''
            to_addr = r['to_address'] or ''

            if from_addr == wallet_lower:
                keep = amount < 0
            elif to_addr == wallet_lower:
                keep = amount > 0
            else:
                keep = amount > 0

            if not keep:
                continue

            symbol = r['symbol'] or ''
            contract = r['contract'] or ''
            symbol_key = _collation_key(symbol)

            self.wallet_transfers_by_hash.setdefault(h, []).append({
                'symbol': symbol,
                'contract': contract,
                'amount': amount,
            })

            self.hash_by_symbol_contract.setdefault((symbol_key, contract), set()).add(h)
            self.hash_by_symbol_any_contract.setdefault(symbol_key, set()).add(h)

    def summary_for_token(self, symbol: str, contract: str = '') -> Dict[str, Dict[str, float]]:
        symbol = (symbol or '').strip().upper()
        contract = (contract or '').strip().lower()

        # direct_token_transactions
        symbol_key = _collation_key(symbol)
        if contract:
            direct_hashes = self.hash_by_symbol_contract.get((symbol_key, contract), set())
        else:
            direct_hashes = self.hash_by_symbol_any_contract.get(symbol_key, set())

        # related_nft_ids: chain+nft_id cua cac direct_hashes co nft_token_id != ''
        related_nft_keys = set()
        for h in direct_hashes:
            chain_v, nft_id = self.selected_tx.get(h, ('', ''))
            if nft_id != '':
                related_nft_keys.add((chain_v, nft_id))

        # text-match: nft_token_id chua symbol (case-insensitive substring), LOCATE
        symbol_lower = symbol.lower()
        text_match_hashes = set()
        # nft-match: cung chain + nft_token_id (BINARY exact) voi related_nft_keys
        nft_match_hashes = set()

        if symbol_lower:
            for h, chain_v, nft_id, nft_id_lower in self.nft_hashes:
                if symbol_lower in nft_id_lower:
                    text_match_hashes.add(h)
                if (chain_v, nft_id) in related_nft_keys:
                    nft_match_hashes.add(h)

        selected_hashes = direct_hashes | text_match_hashes | nft_match_hashes

        # Gom nhom SUM sent/received theo (symbol, contract)
        agg: Dict[Any, Dict[str, Decimal]] = {}
        for h in selected_hashes:
            for d in self.wallet_transfers_by_hash.get(h, []):
                key = (d['symbol'], d['contract'])
                bucket = agg.setdefault(key, {'sent': Decimal('0'), 'received': Decimal('0')})
                if d['amount'] < 0:
                    bucket['sent'] += d['amount']
                else:
                    bucket['received'] += d['amount']

        result = {}
        for (sym, con), bucket in agg.items():
            key = f"{sym}|{con}"
            sent = bucket['sent']
            received = bucket['received']
            result[key] = {
                'sent': _format_decimal(sent),
                'received': _format_decimal(received),
                'total': _format_decimal(sent + received),
            }
        return result