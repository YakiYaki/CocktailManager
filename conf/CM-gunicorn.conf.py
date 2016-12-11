import multiprocessing

bind = "127.0.0.1:8000"
workers = multiprocessing.cpu_count() * 2 + 1
worker_class="gevent"
log-file = "/app/log/gunicorn.log"
access-logfile = "/app/log/gunicorn-access.log"
loglevel = "debug"