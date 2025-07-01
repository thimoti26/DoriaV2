#!/bin/bash

# Script de test de connectivité réseau pour DoriaV2/Linphone
# Aide à diagnostiquer les problèmes de réseau et NAT

echo "🌐 TEST DE CONNECTIVITÉ RÉSEAU - DORIAV2"
echo "========================================"

# Couleurs
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

log_info() { echo -e "${BLUE}${1}${NC}"; }
log_success() { echo -e "${GREEN}✅ ${1}${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  ${1}${NC}"; }
log_error() { echo -e "${RED}❌ ${1}${NC}"; }

# Obtenir les adresses IP
get_network_info() {
    log_info "\n🔍 Informations réseau du serveur..."
    
    # IP locale (localhost)
    echo "   Localhost : 127.0.0.1"
    
    # IP principale
    if command -v hostname &> /dev/null; then
        local main_ip=$(hostname -I 2>/dev/null | awk '{print $1}')
        if [[ -n "$main_ip" ]]; then
            echo "   IP principale : $main_ip"
        fi
    fi
    
    # Toutes les interfaces (Linux/macOS compatible)
    echo ""
    echo "   📡 Interfaces réseau disponibles :"
    if command -v ip &> /dev/null; then
        # Linux
        ip addr show | grep "inet " | grep -v "127.0.0.1" | while read line; do
            local ip=$(echo "$line" | awk '{print $2}' | cut -d'/' -f1)
            local interface=$(echo "$line" | awk '{print $NF}')
            echo "      $interface: $ip"
        done
    elif command -v ifconfig &> /dev/null; then
        # macOS/BSD
        ifconfig | grep "inet " | grep -v "127.0.0.1" | while read line; do
            local ip=$(echo "$line" | awk '{print $2}')
            echo "      $ip"
        done
    fi
}

# Test des ports DoriaV2
test_doria_ports() {
    log_info "\n🔌 Test des ports DoriaV2..."
    
    local ports=("5060" "8080" "3306")
    local port_names=("SIP" "Web" "MySQL")
    
    for i in "${!ports[@]}"; do
        local port="${ports[$i]}"
        local name="${port_names[$i]}"
        
        if docker compose ps | grep -q "0.0.0.0:$port"; then
            log_success "Port $port ($name) ouvert"
        else
            log_warning "Port $port ($name) non accessible depuis l'extérieur"
        fi
    done
}

# Test connectivité SIP locale
test_local_sip() {
    log_info "\n📞 Test connectivité SIP locale..."
    
    if command -v telnet &> /dev/null; then
        if timeout 3 telnet localhost 5060 </dev/null &>/dev/null; then
            log_success "Port SIP 5060 accessible localement"
        else
            log_error "Port SIP 5060 non accessible"
        fi
    else
        if timeout 3 bash -c 'echo > /dev/tcp/localhost/5060' &>/dev/null; then
            log_success "Port SIP 5060 accessible localement"
        else
            log_error "Port SIP 5060 non accessible"
        fi
    fi
}

# Test endpoints PJSIP
test_sip_endpoints() {
    log_info "\n👥 Test des endpoints SIP..."
    
    local endpoint_count=$(docker exec doriav2-asterisk asterisk -rx "pjsip show endpoints" 2>/dev/null | grep -c "100[1-4]" || echo "0")
    
    if [[ $endpoint_count -ge 4 ]]; then
        log_success "Endpoints SIP configurés ($endpoint_count/4)"
    else
        log_warning "Seulement $endpoint_count/4 endpoints trouvés"
    fi
}

# Générer les instructions de configuration
show_connection_instructions() {
    log_info "\n📋 INSTRUCTIONS DE CONFIGURATION LINPHONE"
    echo "========================================="
    echo ""
    
    # Récupérer l'IP principale
    local main_ip=""
    if command -v hostname &> /dev/null; then
        main_ip=$(hostname -I 2>/dev/null | awk '{print $1}')
    fi
    
    echo "🔧 Configuration locale (même machine) :"
    echo "   Domaine     : localhost"
    echo "   Proxy SIP   : sip:localhost:5060"
    echo ""
    
    if [[ -n "$main_ip" ]]; then
        echo "🌐 Configuration distante (autres machines) :"
        echo "   Domaine     : $main_ip"
        echo "   Proxy SIP   : sip:$main_ip:5060"
        echo ""
        echo "🔥 Firewall - Ports à ouvrir sur le serveur :"
        echo "   sudo ufw allow 5060/udp     # SIP signaling"
        echo "   sudo ufw allow 10000:10100/udp  # RTP media"
        echo ""
    fi
    
    echo "🧪 Tests de validation :"
    echo "   1. Extension 100  - Test connectivité"
    echo "   2. Extension *45  - Test audio simple"
    echo "   3. Extension *43  - Test écho complet"
    echo ""
}

# Test connectivité externe (si IP fournie)
test_external_connectivity() {
    local target_ip="$1"
    
    if [[ -z "$target_ip" ]]; then
        return 0
    fi
    
    log_info "\n🌍 Test connectivité externe vers $target_ip..."
    
    # Test ping
    if ping -c 1 -W 3 "$target_ip" &>/dev/null; then
        log_success "Ping vers $target_ip réussi"
    else
        log_warning "Ping vers $target_ip échoué"
    fi
    
    # Test port SIP
    if command -v telnet &> /dev/null; then
        if timeout 3 telnet "$target_ip" 5060 </dev/null &>/dev/null; then
            log_success "Port SIP accessible sur $target_ip"
        else
            log_error "Port SIP non accessible sur $target_ip"
        fi
    fi
}

# Fonction principale
main() {
    echo ""
    
    # Vérifier que Docker fonctionne
    if ! docker compose ps &>/dev/null; then
        log_error "Docker Compose non disponible ou stack non démarrée"
        echo "   Démarrer avec: docker compose up -d"
        exit 1
    fi
    
    # Tests
    get_network_info
    test_doria_ports
    test_local_sip
    test_sip_endpoints
    show_connection_instructions
    
    # Test externe si IP fournie en paramètre
    if [[ -n "$1" ]]; then
        test_external_connectivity "$1"
    fi
    
    echo ""
    log_success "🎉 Test de connectivité terminé !"
    echo ""
    log_info "💡 Usage: $0 [IP_CIBLE]"
    log_info "📖 Guide détaillé : TUTORIEL_LINPHONE.md"
    log_info "🧪 Validation Linphone : ./test-linphone.sh"
    echo ""
}

# Point d'entrée
main "$@"
