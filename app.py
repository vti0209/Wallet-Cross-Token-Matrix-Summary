import os
from flask import Flask, render_template, request, jsonify
from pool_token_summary import get_pool_token_summary

app = Flask(__name__, template_folder="templates", static_folder="static")

# Chống cache trình duyệt triệt để để UI luôn được update mới nhất
@app.after_request
def add_header(response):
    response.headers['Cache-Control'] = 'no-store, no-cache, must-revalidate, post-check=0, pre-check=0, max-age=0'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = '-1'
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type'
    return response

# Trang chủ Rendering
@app.route("/")
@app.route("/pool_token_summary")
@app.route("/pool_token_summary.html")
def index():
    return render_template("pool_token_summary.html")

# API Truy vấn Ma Trận
@app.route("/api/pool-token-summary", methods=["GET", "POST", "OPTIONS"])
def api_pool_token_summary():
    if request.method == "OPTIONS":
        return jsonify({"status": "success"}), 200

    try:
        if request.method == "POST":
            data = request.get_json(silent=True) or request.form
        else:
            data = request.args

        wallet = str(data.get("wallet", "") or "").strip()
        chain = str(data.get("chain", "") or "").strip()
        from_date = str(data.get("from_date", "") or "").strip()
        to_date = str(data.get("to_date", "") or "").strip()

        if not wallet:
            return jsonify({"status": "error", "message": "Wallet address is required."}), 400

        # Lấy dữ liệu ma trận từ DB
        result = get_pool_token_summary(wallet, chain, from_date, to_date)

        return jsonify({
            "status": "success",
            "query": {
                "wallet": wallet, 
                "chain": chain, 
                "from_date": from_date, 
                "to_date": to_date
            },
            "data": result
        })
    except Exception as e:
        app.logger.error(f"Error in api_pool_token_summary: {e}", exc_info=True)
        return jsonify({"status": "error", "message": str(e)}), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)