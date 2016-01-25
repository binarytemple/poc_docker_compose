.phony: build-web run-compose

build-web: 
		docker build -t web .

run-compose:
		docker-compose up

run-web-only:
		docker run -d --name web -p 5000:5000 web

run-redis-only:
		docker run -d --name redis -p 6379:6379 redis
