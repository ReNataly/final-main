FROM golang:1.25-alpine AS builder

WORKDIR /app

# Копируем файлы модуля
COPY go.mod go.sum ./
RUN go mod download

# Копируем исходный код
COPY *.go ./

# Собираем приложение
RUN CGO_ENABLED=0 GOOS=linux go build -o parcel-tracker .

# Финальный образ
FROM alpine:3.19

# Устанавливаем SQLite
RUN apk add --no-cache sqlite ca-certificates

# Создаем пользователя
RUN adduser -D -g '' appuser

USER appuser
WORKDIR /app

# Копируем бинарный файл
COPY --from=builder /app/parcel-tracker .

# Том для данных БД
VOLUME ["/data"]

ENTRYPOINT ["./parcel-tracker"]
