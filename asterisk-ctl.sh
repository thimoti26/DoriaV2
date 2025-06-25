#!/bin/bash

echo "🎯 Gestionnaire du système Asterisk/FreePBX"
echo "==========================================="

case "$1" in
    "start")
        echo "🚀 Démarrage du système..."
        docker compose up -d
        echo "✅ Système démarré"
        echo "🌐 Interface web : http://localhost:8080"
        echo "📞 SIP Server : localhost:5060"
        ;;
    "stop")
        echo "🛑 Arrêt du système..."
        docker compose down
        echo "✅ Système arrêté"
        ;;
    "restart")
        echo "🔄 Redémarrage du système..."
        docker compose down
        docker compose up -d
        echo "✅ Système redémarré"
        ;;
    "status")
        echo "📊 État du système :"
        docker compose ps
        ;;
    "logs")
        service="${2:-asterisk}"
        echo "📋 Logs de $service :"
        docker compose logs -f "$service"
        ;;
    "shell")
        service="${2:-asterisk}"
        echo "🔧 Shell dans $service :"
        docker compose exec "$service" bash
        ;;
    "setup")
        echo "⚙️  Configuration de l'extension osmo..."
        ./scripts/create-osmo-extension.sh
        ;;
    "test")
        echo "🧪 Test de connectivité..."
        ./scripts/status-system.sh
        ;;
    "linphone")
        echo "📱 Configuration Linphone..."
        ./scripts/configure-linphone.sh
        ;;
    "clean")
        echo "🧹 Nettoyage complet..."
        docker compose down -v
        docker system prune -f
        echo "✅ Nettoyage terminé"
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|logs|shell|setup|test|linphone|clean}"
        echo ""
        echo "Commandes disponibles :"
        echo "  start     - Démarrer le système"
        echo "  stop      - Arrêter le système"
        echo "  restart   - Redémarrer le système"
        echo "  status    - Afficher l'état"
        echo "  logs      - Afficher les logs (logs [service])"
        echo "  shell     - Accéder au shell (shell [service])"
        echo "  setup     - Configurer l'extension osmo"
        echo "  test      - Tester la connectivité"
        echo "  linphone  - Guide Linphone"
        echo "  clean     - Nettoyage complet"
        echo ""
        echo "Exemples :"
        echo "  $0 start"
        echo "  $0 logs asterisk"
        echo "  $0 shell freepbx-web"
        ;;
esac
