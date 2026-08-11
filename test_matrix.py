import json
import csv
import time
from datetime import datetime
from pool_token_summary import get_pool_token_summary

def run_test():
    # === INPUT ===
    wallet = '0x88DE2AB47352779494547CaCCB31eE1A133dd334'
    chain = 'BAS'
    from_date = '2026-08-08'
    to_date = ''  # De trong -> lay ngay hien tai

    print("=" * 60)
    print("CROSS-TOKEN MATRIX TEST")
    print(f"Wallet: {wallet}")
    print(f"Chain : {chain.upper()}")
    print(f"From  : {from_date}")
    print(f"To    : {to_date or datetime.now().strftime('%Y-%m-%d')} (default today)")
    print("=" * 60)

    start_time = time.time()

    try:
        payload = get_pool_token_summary(wallet, chain, from_date, to_date)
        execution_time = round((time.time() - start_time) * 1000, 2)

        print(f"\nSUCCESS! ({execution_time} ms)")
        
        tokens = payload.get('tokens', [])
        matrix = payload.get('matrix', {})
        
        print(f"Total tokens: {len(tokens)}")
        
        # === XUAT CSV ===
        csv_file = f'matrix_{wallet[:12]}_{datetime.now().strftime("%Y%m%d")}.csv'
        
        with open(csv_file, 'w', newline='', encoding='utf-8') as f:
            writer = csv.writer(f)
            
            # Header: Token + danh sach cac token cot
            header = ['Token']
            for t in tokens:
                header.append(t['symbol'])
            writer.writerow(header)
            
            # Data: tung hang
            for row_token in tokens:
                row_key = row_token['key']
                row_cells = matrix.get(row_key, {})
                
                row_data = [row_token['symbol']]
                for col_token in tokens:
                    col_key = col_token['key']
                    cell = row_cells.get(col_key, {})
                    
                    if cell.get('has_relation', False):
                        sent = cell.get('sent', 0)
                        received = cell.get('received', 0)
                        # Giu nguyen dau: sent la so am (-), received la so duong (+)
                        row_data.append(f"{sent} | +{received}")
                    else:
                        row_data.append('-')
                
                writer.writerow(row_data)
        
        print(f"CSV exported: {csv_file}")
        
        # === LUU JSON (de debug) ===
        with open('matrix_result.json', 'w', encoding='utf-8') as f:
            json.dump(payload, f, indent=2, ensure_ascii=False, default=str)
        print("JSON saved: matrix_result.json")

    except Exception as e:
        print(f"\nERROR: {e}")
        import traceback
        traceback.print_exc()

if __name__ == '__main__':
    run_test()