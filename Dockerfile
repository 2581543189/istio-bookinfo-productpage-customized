# Copyright Istio Authors
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

FROM python:3.7.7-alpine

WORKDIR /
COPY requirements.txt ./
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
RUN apk add --update musl-dev
RUN apk add --update gcc
RUN pip install --upgrade pip -i https://pypi.tuna.tsinghua.edu.cn/simple
RUN pip install wheel -i https://pypi.tuna.tsinghua.edu.cn/simple
RUN pip install --upgrade setuptools -i https://pypi.tuna.tsinghua.edu.cn/simple
RUN pip install --no-cache-dir -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

COPY test-requirements.txt ./
RUN pip install --no-cache-dir -r test-requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

COPY productpage.py /opt/microservices/
COPY tests/unit/* /opt/microservices/
COPY templates /opt/microservices/templates
COPY static /opt/microservices/static
COPY requirements.txt /opt/microservices/

ARG flood_factor
ENV FLOOD_FACTOR ${flood_factor:-0}
RUN apk add --update curl bash && rm -rf /var/cache/apk/*

EXPOSE 9080
WORKDIR /opt/microservices
RUN python -m unittest discover

CMD ["python", "productpage.py", "9080"]
