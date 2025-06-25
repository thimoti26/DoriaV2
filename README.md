# DoriaV2 E-commerce Platform

A modern e-commerce platform built with PHP and MySQL, containerized with Docker for easy development and deployment.

## 🚀 Quick Start

### Prerequisites
- Docker
- Docker Compose
- Git

### Getting Started

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd DoriaV2
   ```

2. **Start the development environment**
   ```bash
   docker-compose up -d
   ```

3. **Access the services**
   - **Web Application**: http://localhost:8080
   - **phpMyAdmin**: http://localhost:8081
   - **MailHog (Email testing)**: http://localhost:8025

## 🏗️ Architecture

### Services

#### MySQL Database (`mysql`)
- **Image**: Custom built from MySQL 8.0
- **Port**: 3306
- **Database**: `doriav2`
- **User**: `doriav2_user`
- **Password**: `doriav2_password`
- **Root Password**: `doriav2_root_password`

#### Redis Cache (`redis`)
- **Image**: Redis 7 Alpine
- **Port**: 6379
- **Password**: `doriav2_redis_password`
- **Purpose**: Session storage and caching

#### Web Server (`web`)
- **Image**: PHP 8.2 with Apache
- **Port**: 8080
- **Document Root**: `/var/www/html` (mapped to `./src`)

#### phpMyAdmin (`phpmyadmin`)
- **Image**: Latest phpMyAdmin
- **Port**: 8081
- **Purpose**: Database management interface

#### MailHog (`mailhog`)
- **Image**: Latest MailHog
- **Ports**: 8025 (Web UI), 1025 (SMTP)
- **Purpose**: Email testing during development

## 🗄️ Database Schema

The database includes the following tables for a complete e-commerce solution:

- **users**: Customer accounts and authentication
- **categories**: Product categorization with hierarchical support
- **products**: Product catalog with pricing, inventory, and SEO
- **addresses**: Customer shipping and billing addresses
- **orders**: Order management with status tracking
- **order_items**: Individual items within orders
- **shopping_cart**: Persistent shopping cart functionality
- **reviews**: Product reviews and ratings
- **admin_users**: Administrative user accounts

### Sample Data
The database is pre-populated with sample data including:
- 5 product categories
- 3 sample users
- 5 sample products
- 2 admin users
- Sample addresses, cart items, orders, and reviews

## 🔧 Development

### File Structure
```
DoriaV2/
├── docker-compose.yml          # Main orchestration file
├── mysql/                      # MySQL container configuration
│   ├── Dockerfile             # Custom MySQL image
│   ├── my.cnf                 # MySQL configuration
│   └── init.sql               # Database initialization
├── src/                       # Web application source code
│   └── index.php             # Environment test page
└── README.md                  # This file
```

### Environment Variables

The following environment variables are available in the web container:

- `DB_HOST`: MySQL host (default: mysql)
- `DB_NAME`: Database name (default: doriav2)
- `DB_USER`: Database user (default: doriav2_user)
- `DB_PASSWORD`: Database password (default: doriav2_password)
- `REDIS_HOST`: Redis host (default: redis)
- `REDIS_PASSWORD`: Redis password (default: doriav2_redis_password)

### Building and Running

#### Start all services
```bash
docker-compose up -d
```

#### View logs
```bash
docker-compose logs -f [service_name]
```

#### Stop all services
```bash
docker-compose down
```

#### Rebuild containers
```bash
docker-compose build --no-cache
docker-compose up -d
```

#### Access container shells
```bash
# Web container
docker-compose exec web bash

# MySQL container
docker-compose exec mysql bash

# Redis container
docker-compose exec redis sh
```

## 🔍 Database Access

### Via phpMyAdmin
1. Open http://localhost:8081
2. Login with:
   - **Server**: mysql
   - **Username**: doriav2_user
   - **Password**: doriav2_password

### Via Command Line
```bash
# Connect to MySQL container
docker-compose exec mysql mysql -u doriav2_user -p doriav2

# Or as root
docker-compose exec mysql mysql -u root -p
```

### Via External Client
- **Host**: localhost
- **Port**: 3306
- **Database**: doriav2
- **Username**: doriav2_user
- **Password**: doriav2_password

## 📧 Email Testing

MailHog captures all emails sent by the application:

1. Configure your PHP application to use SMTP:
   - **Host**: mailhog
   - **Port**: 1025
   - **No authentication required**

2. View captured emails at http://localhost:8025

## 🔒 Security Notes

> **⚠️ Development Only**: This configuration is for development purposes only. Do not use these credentials or configuration in production.

### Default Credentials
- **MySQL Root**: `doriav2_root_password`
- **MySQL User**: `doriav2_user` / `doriav2_password`
- **Redis**: `doriav2_redis_password`
- **Admin User**: `admin@doriav2.com` / (check database for hashed password)

## 🛠️ Customization

### Adding PHP Extensions
Edit the `web` service command in `docker-compose.yml` to install additional extensions:

```yaml
command: >
  bash -c "
  apt-get update &&
  apt-get install -y [additional-packages] &&
  docker-php-ext-install [extension-name] &&
  apache2-foreground
  "
```

### MySQL Configuration
Modify `mysql/my.cnf` to adjust MySQL settings for your needs.

### Adding Services
Add new services to `docker-compose.yml` as needed (e.g., Elasticsearch, Node.js APIs, etc.).

## 📊 Monitoring

### Health Checks
The MySQL and Redis services include health checks. View status with:
```bash
docker-compose ps
```

### Volume Management
Data persists in named Docker volumes:
- `doriav2_mysql_data`: Database files
- `doriav2_redis_data`: Redis data
- `doriav2_mysql_logs`: MySQL logs
- `doriav2_web_logs`: Apache logs

## 🚀 Next Steps

1. **Implement Authentication**: Build user registration/login system
2. **Product Management**: Create admin interface for products
3. **Shopping Cart**: Implement cart functionality
4. **Payment Integration**: Add payment gateway (Stripe, PayPal)
5. **Order Management**: Build order processing system
6. **Email Notifications**: Set up transactional emails
7. **API Development**: Create REST API for mobile apps
8. **Search & Filtering**: Add product search capabilities
9. **Performance**: Implement caching strategies
10. **Testing**: Add unit and integration tests

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

[Add your license information here]
