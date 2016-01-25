.phony: build-web compose-restart compose compose-force-recreate web-only redis-only

build-web: 
		docker build -t web .

compose-restart:
		docker-compose restart

compose:
		docker-compose up -d

compose-force-recreate:
		docker-compose up --force-recreate -d

web-only:
		docker run -d --name web -p 5000:5000 web

redis-only:
		docker run -d --name redis -p 6379:6379 redis
