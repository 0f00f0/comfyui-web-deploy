#!/bin/bash
set -e  # 遇到错误立即停止

# 配置参数（需根据实际修改）
COMFYUI_IP="42.192.108.200"     # ComfyUI 服务器的 IP
COMFYUI_PORT="6889"        # ComfyUI 的端口

# 安装系统依赖
apt-get update
apt-get install -y python3-pip python3-venv nginx git

# 克隆代码到服务器
git clone https://github.com/your-username/comfyui-web-deploy.git /opt/comfyui-web
cd /opt/comfyui-web

# 配置 Python 虚拟环境
python3 -m venv venv
source venv/bin/activate
pip install -r backend/requirements.txt

# 配置系统服务（Flask 后端）
cat <<EOF > /etc/systemd/system/comfyui-web.service
[Unit]
Description=ComfyUI Web Backend
After=network.target

[Service]
User=root
WorkingDirectory=/opt/comfyui-web/backend
Environment="COMFYUI_IP=$COMFYUI_IP"
Environment="COMFYUI_PORT=$COMFYUI_PORT"
ExecStart=/opt/comfyui-web/venv/bin/python app.py

[Install]
WantedBy=multi-user.target
EOF

# 配置 Nginx 反向代理
cp nginx-config/comfyui-web.conf /etc/nginx/sites-available/
ln -s /etc/nginx/sites-available/comfyui-web.conf /etc/nginx/sites-enabled/
systemctl restart nginx

# 启动服务
systemctl daemon-reload
systemctl enable comfyui-web
systemctl start comfyui-web

echo "部署完成！访问地址: http://$(curl -s ifconfig.me)"
