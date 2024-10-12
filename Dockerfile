FROM golang:latest

WORKDIR /app

RUN go install github.com/playwright-community/playwright-go/cmd/playwright@latest
RUN playwright install --with-deps

COPY go.mod main.go ./
RUN go mod tidy
RUN go build -o main main.go

ENTRYPOINT ["/app/main"]