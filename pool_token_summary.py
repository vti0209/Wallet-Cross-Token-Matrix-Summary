from decimal import Decimal
from datetime import datetime
from wallet_matrix import generate_cross_token_matrix


def safe_float(val):
    if val is None:
        return 0.0
    try:
        return float(val)
    except (ValueError, TypeError):
        return 0.0


def get_pool_token_summary(wallet, chain, from_date, to_date):
    if not to_date:
        to_date = datetime.now().strftime('%Y-%m-%d')
    
    matrix_payload = generate_cross_token_matrix(wallet, chain, from_date, to_date)
    
    headers = matrix_payload.get('headers', [])
    rows_payload = matrix_payload.get('rows', [])
    
    tokens_list = [
        {
            "key": h['key'],
            "symbol": h['symbol'],
            "contract": h['contract'],
            "label": f"{h['symbol']} ({h['contract'][:6]}...)" if h.get('contract') else h['symbol']
        }
        for h in headers
    ]
    
    matrix_out = {}
    for r in rows_payload:
        r_key = r['row_token']['key']
        row_cells = {}
        has_any_relation = False
        
        for c_key, cell in r.get('cells', {}).items():
            sent_v = safe_float(cell.get('sent', 0))
            received_v = safe_float(cell.get('received', 0))
            touched = bool(cell.get('touched', False))
            
            if touched:
                has_any_relation = True
            
            row_cells[c_key] = {
                "sent": sent_v,
                "received": received_v,
                "has_relation": touched
            }
        
        # CHI LUU HANG NEU CO IT NHAT 1 MOI QUAN HE
        if has_any_relation:
            matrix_out[r_key] = row_cells
    
    flow_rows = []
    for h in headers:
        k = h['key']
        row = matrix_out.get(k, {})
        out_total = 0.0
        in_total = 0.0
        
        for c_key, cell in row.items():
            if cell.get('has_relation', False):
                out_total += abs(safe_float(cell.get('sent', 0)))
                in_total += abs(safe_float(cell.get('received', 0)))
        
        # CHI LUU FLOW NEU CO IT NHAT 1 MOI QUAN HE
        if out_total > 0 or in_total > 0:
            flow_rows.append({
                "key": k,
                "symbol": h['symbol'],
                "contract": h['contract'],
                "out": out_total,
                "in": in_total
            })
    
    return {
        "flow": flow_rows,
        "tokens": tokens_list,
        "matrix": matrix_out
    }