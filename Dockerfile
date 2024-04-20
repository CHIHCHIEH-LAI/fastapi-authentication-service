FROM python:3.10
EXPOSE 8000
WORKDIR /app
COPY ./app /app/app
COPY main.py /app
COPY requirements.txt /app
RUN pip install -r requirements.txt
ENV MYSQL_HOST=localhost \
    MYSQL_USER=root \
    MYSQL_PASSWORD=root \
    MYSQL_DB=accountDB
CMD ["python", "main.py"]
