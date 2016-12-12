import multiprocessing

bind = "127.0.0.1:8000"
workers = multiprocessing.cpu_count() * 2 + 1
errorlog = "/app/log/gunicorn-error.log"
accesslog = "/app/log/gunicorn-access.log"
loglevel = "debug"
