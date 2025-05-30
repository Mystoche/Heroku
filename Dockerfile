# Utiliser l'image Nginx légère
FROM nginx:alpine

# Supprimer le contenu par défaut de Nginx
RUN rm -rf /usr/share/nginx/html/*

# Copier ton site statique dans le dossier HTML de Nginx
COPY . /usr/share/nginx/html

# Exposer le port 80
EXPOSE 80

# Nginx démarre automatiquement (pas besoin de CMD)
