.PHONY: exists-code download-wordpress create-wp-config docker-compose

exists-code:
	mkdir -p ./code

download-wordpress: exists-code
	test -d ./code/wordpress || curl https://wordpress.org/latest.tar.gz | tar -xvzf - -C ./code/

docker-compose:	download-wordpress
	docker-compose up 

docker-compose-detached: download-wordpress
	docker-compose up -d 
