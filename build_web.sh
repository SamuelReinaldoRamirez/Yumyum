#!/bin/bash

# Construire le projet Flutter pour le Web
flutter build web

# Copier le fichier explore.html dans le répertoire de construction
cp public/explore.html build/web/