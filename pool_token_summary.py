from decimal import Decimal
from wallet_matrix import get_transactions_from_db, generate_cross_token_matrix


def safe_float(val):
    """Chuyển đổi giá trị sang float an toàn, tránh crash khi dính None"""
    if val is None:
        return 0.0
    try:
        return float(val)
    except (ValueError, TypeError):
        return 0.0


def get_pool_token_summary(wallet, chain, from_date, to_date):
    # Lấy giao dịch từ DB
    transactions = get_transactions_from_db(wallet, chain, from_date, to_date)
    matrix_payload = generate_cross_token_matrix(transactions)

    headers = matrix_payload.get('headers', [])
    rows_payload = matrix_payload.get('rows', [])

    # Chuẩn hóa danh sách Tokens
    tokens_list = [
        {
            "key": h['key'],
            "symbol": h['symbol'],
            "contract": h['contract'],
            "label": f"{h['symbol']} ({h['contract'][:6]}...)" if h.get('contract') else h['symbol']
        }
        for h in headers
    ]

    # Xử lý Ma trận giao dịch
    matrix_out = {}
    for r in rows_payload:
        r_key = r['row_token']['key']
        row_cells = {}
        for c_key, cell in r.get('cells', {}).items():
            out_v = safe_float(cell.get('out', 0))
            in_v = safe_float(cell.get('in', 0))
            touched = bool(cell.get('touched', False))

            row_cells[c_key] = {
                # out để dạng số DƯƠNG (magnitude), giống bản gốc trước đây.
                # FE đang tự thêm dấu "-" khi render -> nếu BE cũng trả số âm sẽ bị double-negative ("--...").
                # Muốn hiển thị "-339.769" thì để FE nối chuỗi, KHÔNG đổi giá trị số ở đây thành âm.
                "out": abs(out_v),
                "out_color": "red",

                # in để dạng số DƯƠNG (magnitude)
                "in": abs(in_v),
                "in_color": "green",

                # touched: cờ QUYẾT ĐỊNH có vẽ ô này không, KHÔNG được suy từ out/in == 0 nữa.
                #   touched = False -> DB không có tx nào chứa cặp token này -> FE hiển thị "-"
                #   touched = True  -> có tx thật -> FE PHẢI hiển thị cả out lẫn in, kể cả = 0
                "has_relation": touched,
            }
        matrix_out[r_key] = row_cells

    # Tính tổng Dòng tiền Out/In cho từng Token (chỉ cộng các ô đã touched)
    flow_rows = []
    for h in headers:
        k = h['key']
        row = matrix_out.get(k, {})
        out_total = sum(
            abs(safe_float(c.get('out', 0))) for c in row.values() if c.get('has_relation')
        )
        in_total = sum(
            safe_float(c.get('in', 0)) for c in row.values() if c.get('has_relation')
        )

        flow_rows.append({
            "key": k,
            "symbol": h['symbol'],
            "contract": h['contract'],
            "out": float(out_total),  # magnitude dương, đồng bộ với matrix bên trên
            "in": float(in_total)
        })

    return {
        "flow": flow_rows,
        "tokens": tokens_list,
        "matrix": matrix_out
    }