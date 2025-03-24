# build frontend
FROM node:23 as fe
WORKDIR /src
RUN npm i -g pnpm
# COPY .git .git/
RUN git init && \
    git config --global user.email "temporary@example.com" && \
    git config --global user.name "Temporary User" && \
    git add . && \
    git commit -m "Temporary commit for build" || true
COPY frontend ./frontend
COPY scripts.sh .
RUN ./scripts.sh build-frontend

# build backend
FROM golang:1.23 as be
WORKDIR /src
COPY . ./
COPY --from=fe /src/frontend/build ./frontend/build/
RUN ./scripts.sh build-backend

# deploy
FROM alpine:3.21.0
LABEL org.opencontainers.image.source="https://github.com/0x2E/fusion"
WORKDIR /fusion
COPY --from=be /src/build/fusion ./
EXPOSE 8080
RUN mkdir /data
ENV DB="/data/fusion.db"
CMD [ "./fusion" ]
