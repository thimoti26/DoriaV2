// Gestion des utilisateurs SIP
class UsersManagement {
    constructor() {
        this.users = [];
        this.currentEditingUser = null;
        this.init();
    }

    init() {
        this.loadUsers();
        this.setupEventListeners();
    }

    setupEventListeners() {
        // Formulaire d'utilisateur
        document.getElementById('userForm').addEventListener('submit', (e) => {
            e.preventDefault();
            this.saveUser();
        });

        // Fermer modal en cliquant en dehors
        window.addEventListener('click', (e) => {
            const modal = document.getElementById('userModal');
            if (e.target === modal) {
                this.closeUserModal();
            }
        });
    }

    async loadUsers() {
        try {
            this.showLoading(true);
            const response = await fetch('api/users-management.php?action=list');
            const data = await response.json();
            
            if (data.success) {
                this.users = data.users;
                this.renderUsers();
                this.updateUserCount();
            } else {
                this.showError('Erreur lors du chargement des utilisateurs: ' + data.error);
            }
        } catch (error) {
            this.showError('Erreur de connexion: ' + error.message);
        } finally {
            this.showLoading(false);
        }
    }

    renderUsers() {
        const container = document.getElementById('usersContainer');
        
        if (this.users.length === 0) {
            container.innerHTML = '<div class="loading">Aucun utilisateur configuré</div>';
            container.style.display = 'block';
            return;
        }

        const usersHtml = this.users.map(user => this.renderUserCard(user)).join('');
        container.innerHTML = usersHtml;
        container.style.display = 'grid';
    }

    renderUserCard(user) {
        const statusClass = user.status === 'online' ? 'status-online' : 'status-offline';
        const statusText = user.status === 'online' ? 'En ligne' : 'Hors ligne';
        
        return `
            <div class="user-card" id="user-${user.id}">
                <div class="user-header">
                    <div class="user-id">${user.id}</div>
                    <div class="user-status ${statusClass}">${statusText}</div>
                </div>
                <div class="user-info">
                    <div><strong>Nom:</strong> ${user.displayName}</div>
                    <div><strong>Contexte:</strong> ${user.context}</div>
                    <div><strong>Contact:</strong> ${user.contact || 'Non enregistré'}</div>
                    <div><strong>Dernière activité:</strong> ${user.lastActivity || 'Jamais'}</div>
                </div>
                <div class="user-actions">
                    <button class="btn btn-edit" onclick="usersManager.editUser('${user.id}')">
                        <i class="fas fa-edit"></i> Modifier
                    </button>
                    <button class="btn btn-delete" onclick="usersManager.deleteUser('${user.id}')">
                        <i class="fas fa-trash"></i> Supprimer
                    </button>
                </div>
            </div>
        `;
    }

    openAddUserModal() {
        this.currentEditingUser = null;
        document.getElementById('modalTitle').textContent = 'Ajouter un utilisateur';
        document.getElementById('userForm').reset();
        document.getElementById('originalUserId').value = '';
        document.getElementById('context').value = 'from-internal';
        document.getElementById('userModal').style.display = 'block';
    }

    editUser(userId) {
        const user = this.users.find(u => u.id === userId);
        if (!user) return;

        this.currentEditingUser = user;
        document.getElementById('modalTitle').textContent = 'Modifier l\'utilisateur';
        document.getElementById('originalUserId').value = user.id;
        document.getElementById('userId').value = user.id;
        document.getElementById('displayName').value = user.displayName;
        document.getElementById('password').value = ''; // Ne pas pré-remplir le mot de passe
        document.getElementById('context').value = user.context;
        document.getElementById('userModal').style.display = 'block';
    }

    async deleteUser(userId) {
        if (!confirm(`Êtes-vous sûr de vouloir supprimer l'utilisateur ${userId} ?`)) {
            return;
        }

        try {
            const response = await fetch('api/users-management.php', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    action: 'delete',
                    userId: userId
                })
            });

            const data = await response.json();
            
            if (data.success) {
                this.showSuccess(`Utilisateur ${userId} supprimé avec succès`);
                this.loadUsers(); // Recharger la liste
            } else {
                this.showError('Erreur lors de la suppression: ' + data.error);
            }
        } catch (error) {
            this.showError('Erreur de connexion: ' + error.message);
        }
    }

    async saveUser() {
        const formData = new FormData(document.getElementById('userForm'));
        const userData = {
            action: this.currentEditingUser ? 'update' : 'create',
            originalUserId: document.getElementById('originalUserId').value,
            userId: formData.get('userId'),
            displayName: formData.get('displayName'),
            password: formData.get('password'),
            context: formData.get('context') || 'from-internal'
        };

        try {
            const response = await fetch('api/users-management.php', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(userData)
            });

            const data = await response.json();
            
            if (data.success) {
                const action = this.currentEditingUser ? 'modifié' : 'créé';
                this.showSuccess(`Utilisateur ${userData.userId} ${action} avec succès`);
                this.closeUserModal();
                this.loadUsers(); // Recharger la liste
            } else {
                this.showError('Erreur lors de la sauvegarde: ' + data.error);
            }
        } catch (error) {
            this.showError('Erreur de connexion: ' + error.message);
        }
    }

    closeUserModal() {
        document.getElementById('userModal').style.display = 'none';
        this.currentEditingUser = null;
    }

    async reloadAsteriskConfig() {
        try {
            const response = await fetch('api/users-management.php', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    action: 'reload'
                })
            });

            const data = await response.json();
            
            if (data.success) {
                this.showSuccess('Configuration Asterisk rechargée avec succès');
                this.loadUsers(); // Recharger pour mettre à jour les statuts
            } else {
                this.showError('Erreur lors du rechargement: ' + data.error);
            }
        } catch (error) {
            this.showError('Erreur de connexion: ' + error.message);
        }
    }

    updateUserCount() {
        const count = this.users.length;
        const text = count === 0 ? 'Aucun utilisateur' : 
                     count === 1 ? '1 utilisateur' : 
                     `${count} utilisateurs`;
        document.getElementById('userCount').textContent = text;
    }

    showLoading(show) {
        document.getElementById('loadingDiv').style.display = show ? 'block' : 'none';
        document.getElementById('usersContainer').style.display = show ? 'none' : 'grid';
    }

    showSuccess(message) {
        const alert = document.getElementById('successAlert');
        alert.textContent = message;
        alert.style.display = 'block';
        setTimeout(() => alert.style.display = 'none', 5000);
        this.hideError();
    }

    showError(message) {
        const alert = document.getElementById('errorAlert');
        alert.textContent = message;
        alert.style.display = 'block';
        this.hideSuccess();
    }

    hideSuccess() {
        document.getElementById('successAlert').style.display = 'none';
    }

    hideError() {
        document.getElementById('errorAlert').style.display = 'none';
    }
}

// Fonctions globales pour les événements onclick
let usersManager;

function openAddUserModal() {
    usersManager.openAddUserModal();
}

function closeUserModal() {
    usersManager.closeUserModal();
}

function reloadAsteriskConfig() {
    usersManager.reloadAsteriskConfig();
}

// Initialiser quand le DOM est prêt
document.addEventListener('DOMContentLoaded', () => {
    usersManager = new UsersManagement();
});
