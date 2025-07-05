all : up

up :
	@mkdir -p /home/candriam/data/wordpress
	@mkdir -p /home/candriam/data/mariadb
	@mkdir -p /home/candriam/data/certs
	@cd srcs && docker compose up -d --build

down :
	@cd srcs && docker compose down

status :
	@docker ps

clean : down
	@docker system prune -af
	@docker volume rm -f srcs_wordpress_data srcs_mariadb_data srcs_certs || true
	@sudo rm -rf /home/candriam/data

fclean : clean
	@docker volume prune -f

re : fclean all

.PHONY: all up down status clean fclean re
