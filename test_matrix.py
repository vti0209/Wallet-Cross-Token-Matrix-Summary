import json
import time
from pool_token_summary import get_pool_token_summary

def run_test():
    # Thông số test
    wallet = '8x4zj74myKzox48jUMHskfNo4NHuAzXeLyXs7HLUSyzL'
    chain = 'sol'
    from_date = '2026-01-01'
    to_date = '2026-08-07'

    print("==================================================")
    print("🚀 ĐANG KẾT NỐI DATABASE VÀ TÍNH MA TRẬN...")
    print(f"👉 Wallet   : {wallet}")
    print(f"👉 Chain    : {chain.upper()}")
    print(f"👉 From-To  : {from_date} -> {to_date}")
    print("==================================================\n")

    start_time = time.time()

    try:
        payload = get_pool_token_summary(wallet, chain, from_date, to_date)
        execution_time = round((time.time() - start_time) * 1000, 2)

        print(f"✅ SUCCESS! LẤY DỮ LIỆU THÀNH CÔNG TỪ DB SERVER! ({execution_time} ms)\n")

        # In tổng quan Flow Token
        flow_list = payload.get('flow', [])
        tokens_list = payload.get('tokens', [])
        
        print(f"📌 TỔNG SỐ TOKEN TÌM THẤY: {len(tokens_list)}")
        print("-" * 50)
        print(f"{'SYMBOL':<12} | {'OUT TOTAL':<15} | {'IN TOTAL':<15}")
        print("-" * 50)
        for item in flow_list:
            print(f"{item['symbol']:<12} | {item['out']:<15.4f} | {item['in']:<15.4f}")
        print("-" * 50)

        # In Full JSON Payload để inspect sâu
        print("\n📄 FULL JSON PAYLOAD:")
        print(json.dumps(payload, indent=2, ensure_ascii=False))

    except Exception as e:
        print("❌ ERROR! LỖI KẾT NỐI DB HOẶC XỬ LÝ DỮ LIỆU:")
        print(e)
        import traceback
        traceback.print_exc()

if __name__ == '__main__':
    run_test()