from flask import Flask, render_template_string

app = Flask(__name__)

TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI Code Template</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #0f0c29, #302b63, #24243e);
            color: #e0e0e0;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .card {
            background: rgba(255,255,255,0.05);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255,255,255,0.1);
            border-radius: 16px;
            padding: 3rem;
            max-width: 600px;
            text-align: center;
        }
        h1 { font-size: 2rem; margin-bottom: 0.5rem; color: #fff; }
        .subtitle { color: #a0a0c0; margin-bottom: 2rem; }
        .tools {
            display: flex;
            gap: 1rem;
            justify-content: center;
            margin-bottom: 2rem;
        }
        .tool {
            background: rgba(255,255,255,0.08);
            border: 1px solid rgba(255,255,255,0.15);
            border-radius: 12px;
            padding: 1.2rem;
            flex: 1;
        }
        .tool h3 { color: #7c8aff; margin-bottom: 0.3rem; font-size: 0.95rem; }
        .tool p { font-size: 0.8rem; color: #999; }
        .status { font-size: 0.85rem; color: #6c6; }
    </style>
</head>
<body>
    <div class="card">
        <h1>AI Code Template</h1>
        <p class="subtitle">Your AI-powered DevSpaces workspace is running</p>
        <div class="tools">
            <div class="tool">
                <h3>Cline</h3>
                <p>VS Code sidebar AI agent</p>
            </div>
            <div class="tool">
                <h3>OpenCode</h3>
                <p>Terminal AI agent</p>
            </div>
        </div>
        <p class="status">Flask server running on port 8080</p>
    </div>
</body>
</html>
"""

@app.route("/")
def index():
    return render_template_string(TEMPLATE)

@app.route("/health")
def health():
    return {"status": "ok"}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080, debug=True)
