# Этап 1: Сборка приложения
FROM golang:1.22-alpine AS builder

WORKDIR /app

# Копируем файлы зависимостей
COPY go.mod go.sum ./
RUN go mod download

# Копируем исходный код
COPY *.go ./

# Собираем статический бинарный файл
RUN CGO_ENABLED=0 GOOS=linux go build -o /parcel-service .

# Этап 2: Финальный образ
FROM alpine:3.19

# Устанавливаем SQLite и создаем пользователя
RUN apk add --no-cache sqlite
RUN adduser -D -g '' appuser

WORKDIR /app

# Копируем бинарный файл из этапа сборки
COPY --from=builder /parcel-service .

# Создаем директорию для данных
RUN mkdir -p /data && chown -R appuser:appuser /app /data

USER appuser
VOLUME ["/data"]
WORKDIR /data

# Создаем таблицу при запуске и запускаем приложение
ENTRYPOINT ["sh", "-c", "sqlite3 /data/tracker.db 'CREATE TABLE IF NOT EXISTS parcel (number INTEGER PRIMARY KEY AUTOINCREMENT, client INTEGER NOT NULL, status TEXT NOT NULL, address TEXT NOT NULL, created_at TEXT NOT NULL);' && /app/parcel-service"]
