# build =============================================# 
FROM golang:1.24 AS builder

WORKDIR /app

# Cache dependencies
COPY go.mod ./
RUN go mod download

# Copy source code
COPY . .

# Build statically linked binary
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o main .

# minimal runtime====================================# 

FROM scratch

# Add static files (if needed)
COPY --from=builder /app/static /static
COPY --from=builder /app/templates /templates

# Copy the statically linked binary
COPY --from=builder /app/main /main

# Set binary as entrypoint
ENTRYPOINT ["/main"]
