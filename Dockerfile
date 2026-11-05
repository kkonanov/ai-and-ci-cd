FROM python:3.12-slim
WORKDIR /srv
COPY app/ app/
EXPOSE 8080
CMD ["python", "-m", "app.server"]
