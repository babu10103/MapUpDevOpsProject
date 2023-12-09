FROM python:alpine

WORKDIR /app

COPY . .

CMD ["python", "app.py"]
