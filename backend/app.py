from flask import Flask, request, jsonify
import requests
import os

app = Flask(__name__)
COMFYUI_API = f"http://{os.getenv('COMFYUI_IP', 'localhost')}:{os.getenv('COMFYUI_PORT', '8188')}/prompt"

@app.route('/generate', methods=['POST'])
def generate():
    data = request.json
    try:
        response = requests.post(COMFYUI_API, json=data)
        response.raise_for_status()
        return jsonify(response.json())
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
