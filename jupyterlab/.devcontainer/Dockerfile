FROM jupyter/scipy-notebook:latest
FROM python:3.8-slim

# メタ情報の付与
LABEL maintainer = "s.kitaoka36@gmail.com"
LABEL version = "1.0"
LABEL description = "jupyterlab"

# ワークディレクトリを設定
ARG project_dir=/home/jovyan
WORKDIR $project_dir

# ファイルのコピー
COPY requirements.txt ${PWD}

# pythonのパッケージをインストール
RUN pip install -r requirements.txt

RUN jupyter serverextension enable --py jupyterlab


