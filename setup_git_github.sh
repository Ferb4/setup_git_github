#!/bin/bash

set -e

echo " Mise à jour du système et installation de Git & dépendances..."
sudo apt update -y && sudo apt install -y git curl openssh-client jq

# === CONFIGURATION GIT ===
read -p "Entrez votre nom complet (Git): " git_name
read -p "Entrez votre email (Git): " git_email
git config --global user.name "$git_name"
git config --global user.email "$git_email"
echo " Git configuré avec nom: $git_name, email: $git_email"

# === CLÉ SSH ===
SSH_KEY="$HOME/.ssh/id_rsa"
if [[ -f "$SSH_KEY" ]]; then
  echo " Clé SSH déjà existante détectée à $SSH_KEY"
else
  echo " Génération d'une nouvelle clé SSH..."
  ssh-keygen -t rsa -b 4096 -C "$git_email" -f "$SSH_KEY" -N ""
  echo " Nouvelle clé SSH générée."
fi

# Ajouter la clé à l’agent SSH
eval "$(ssh-agent -s)"
ssh-add "$SSH_KEY"

# === AJOUT AUTOMATIQUE À GITHUB ? ===
echo ""
read -p "Souhaitez-vous ajouter automatiquement cette clé SSH à votre compte GitHub ? (y/n): " add_key

if [[ "$add_key" == "y" || "$add_key" == "Y" ]]; then
  echo ""
  echo " Pour ajouter la clé automatiquement, vous avez besoin d’un GitHub Personal Access Token."
  echo " Voici comment le générer :"
  echo "1. Rendez-vous sur : https://github.com/settings/tokens"
  echo "2. Cliquez sur : Generate new token (classic)"
  echo "3. Donnez un nom au token (ex: SSH DevOps Script)"
  echo "4. Expiration : choisissez 30, 90 jours ou 'No expiration'"
  echo "5. Cochez uniquement :  admin:public_key"
  echo "6. Cliquez sur 'Generate token'"
  echo "Copiez immédiatement le token affiché, il ne sera plus visible après !"
  echo ""

  read -p "Entrez votre GitHub username: " github_user
  echo -n "Entrez le GitHub Personal Access Token (il ne s'affichera pas) : "
  read -s github_token
  echo ""

  PUB_KEY=$(cat "$SSH_KEY.pub")
  TITLE="$(hostname)-$(date +%Y%m%d%H%M%S)"

  echo "Ajout automatique de la clé SSH à votre compte GitHub..."
  response=$(curl -s -w "%{http_code}" -o /tmp/github_response.json \
    -u "$github_user:$github_token" \
    -X POST https://api.github.com/user/keys \
    -H "Content-Type: application/json" \
    -d "{\"title\": \"$TITLE\", \"key\": \"$PUB_KEY\"}")

  if [[ "$response" == "201" ]]; then
    echo "Clé SSH ajoutée avec succès à GitHub."
  else
    echo "Échec de l'ajout automatique. Code HTTP: $response"
    echo "Réponse complète :"
    cat /tmp/github_response.json
    echo ""
    echo " Vous pouvez ajouter manuellement la clé suivante à GitHub ici :"
    echo " https://github.com/settings/ssh/new"
    echo ""
    echo "$PUB_KEY"
  fi
else
  echo ""
  echo " Voici votre clé SSH publique. Copiez-la et ajoutez-la à GitHub manuellement ici :"
  echo " https://github.com/settings/ssh/new"
  echo ""
  cat "$SSH_KEY.pub"
fi

# === TEST DE CONNEXION SSH ===
echo ""
echo " Test de connexion SSH à GitHub..."
ssh -T git@github.com || echo "Connexion échouée. Vérifiez si la clé est bien ajoutée à GitHub."

# === CONFIGURATION GIT POUR UTILISER SSH PAR DÉFAUT ===
git config --global url."git@github.com:".insteadOf "https://github.com/"
echo "✅ Git configuré pour utiliser SSH automatiquement."

echo ""
echo "Tout est prêt ! Vous pouvez maintenant cloner, puller et pusher vos projets GitHub sans mot de passe."

