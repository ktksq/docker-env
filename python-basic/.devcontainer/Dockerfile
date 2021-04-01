FROM python:3.8-slim

# メタ情報の付与
LABEL maintainer = "s.kitaoka36@gmail.com"
LABEL version = "1.0"
LABEL description = "Python Basic"

RUN apt-get update && apt-get install -y tzdata \
    && rm -rf /var/lib/apt/lists/*

# 作業ディレクトリを変更
WORKDIR /tmp/work

# ファイルのコピー
COPY requirements.txt ${PWD}

# pythonのパッケージをインストール
RUN pip install -r requirements.txt

# 環境変数の定義
ENV TZ = Asia/Tokyo