workspace "Flask Three-Tier Application" "C4 architecture model for a simplified Flask application deployed on Azure for learning application development" {

    !identifiers hierarchical

    configuration {
        scope softwaresystem
    }

    model {
        # Actors
        user = person "Application User" "Interacts with the demo application" {
            tags "Primary Actor"
            properties {
                "Actor Type" "Primary"
                "Frequency" "High"
                "Trust Level" "External, untrusted"
            }
            perspectives {
                "Business" "Main user, interacts with demo form"
                "Security" "External user, requires input validation"
            }
        }
        developer = person "Developer" "Deploys and maintains the application" {
            tags "Primary Actor"
            properties {
                "Actor Type" "Secondary"
                "Frequency" "Medium"
                "Trust Level" "Internal, trusted"
            }
            perspectives {
                "Business" "Deploys application, monitors health"
                "Security" "SSH access directly to VM"
            }
        }

        # The System
        flaskApp = softwareSystem "Flask Three-Tier Application" "Demo application showing Flask with PostgreSQL on Azure" {

            !docs docs
            !adrs adrs

            # Client-side Containers
            group "Client" {
                browser = container "Web Browser" "Renders HTML pages and forms" "Chrome, Firefox, Safari" {
                    tags "Client" "Primary Client"
                }

                terminal = container "Terminal" "Command-line interface for deployment and administration" "SSH, Azure CLI" {
                    tags "Client" "Secondary Client"
                }
            }

            # Server-side Containers
            group "Server" {
                appServer = container "Application Server" "Combined nginx reverse proxy and Flask application" "Ubuntu 24.04, nginx, Gunicorn" {
                    tags "Application"

                    # nginx Components
                    nginxProxy = component "nginx Reverse Proxy" "SSL termination and request forwarding" "nginx"
                    sslCert = component "SSL Certificate" "Self-signed TLS certificate" "OpenSSL"

                    # Flask Components
                    wsgi = component "WSGI Server" "Production HTTP server" "Gunicorn"
                    mainRoutes = component "Main Blueprint" "Landing page route" "Flask @main_bp"
                    demoRoutes = component "Demo Blueprint" "Demo form and entry management" "Flask @demo_bp"
                    apiRoutes = component "API Blueprint" "Health and entries endpoints" "Flask @api_bp"
                    templates = component "Template Engine" "HTML rendering" "Jinja2"
                    models = component "Data Models" "SQLAlchemy ORM" "Entry model"
                    services = component "Service Layer" "Business logic" "EntryService"
                }

                database = container "PostgreSQL Database" "Stores application data" "Azure PostgreSQL Flexible Server" {
                    tags "Database"
                }
            }
        }

        # Relationships - Context Level
        user -> flaskApp "Uses demo application" "HTTPS"
        developer -> flaskApp "Deploys and monitors" "SSH, HTTPS"

        # Relationships - Container Level
        user -> flaskApp.browser "Uses" "Mouse, keyboard"
        developer -> flaskApp.browser "Views application" "Mouse, keyboard"
        developer -> flaskApp.terminal "Uses" "Keyboard"

        flaskApp.browser -> flaskApp.appServer "HTTPS requests" "HTTPS/443"
        flaskApp.terminal -> flaskApp.appServer "SSH access" "SSH/22"

        flaskApp.appServer -> flaskApp.database "Reads/writes data" "PostgreSQL/5432"

        # Relationships - Component Level
        flaskApp.browser -> flaskApp.appServer.nginxProxy "HTTPS requests" "HTTPS/443" {
            tags "ComponentLevel"
        }
        flaskApp.appServer.nginxProxy -> flaskApp.appServer.sslCert "Uses" "TLS" {
            tags "ComponentLevel"
        }
        flaskApp.appServer.nginxProxy -> flaskApp.appServer.wsgi "Forwards requests" "HTTP/5001" {
            tags "ComponentLevel"
        }

        flaskApp.appServer.wsgi -> flaskApp.appServer.mainRoutes "Routes /" "WSGI" {
            tags "ComponentLevel"
        }
        flaskApp.appServer.wsgi -> flaskApp.appServer.demoRoutes "Routes /demo" "WSGI" {
            tags "ComponentLevel"
        }
        flaskApp.appServer.wsgi -> flaskApp.appServer.apiRoutes "Routes /api" "WSGI" {
            tags "ComponentLevel"
        }

        flaskApp.appServer.mainRoutes -> flaskApp.appServer.templates "Renders HTML" "Jinja2" {
            tags "ComponentLevel"
        }
        flaskApp.appServer.demoRoutes -> flaskApp.appServer.templates "Renders HTML" "Jinja2" {
            tags "ComponentLevel"
        }
        flaskApp.appServer.demoRoutes -> flaskApp.appServer.services "CRUD operations" "Python" {
            tags "ComponentLevel"
        }
        flaskApp.appServer.apiRoutes -> flaskApp.appServer.services "Query entries" "Python" {
            tags "ComponentLevel"
        }

        flaskApp.appServer.services -> flaskApp.appServer.models "Uses" "SQLAlchemy" {
            tags "ComponentLevel"
        }
        flaskApp.appServer.models -> flaskApp.database "SQL queries" "psycopg2" {
            tags "ComponentLevel"
        }

        # Deployment - Azure IaaS (Simplified)
        production = deploymentEnvironment "Production" {
            deploymentNode "User Environment" "User's local machine" "Desktop/Laptop" {
                deploymentNode "Web Browser" "User's web browser" "Chrome, Firefox, Safari" {
                    browserInstance = containerInstance flaskApp.browser
                }
                deploymentNode "Terminal" "Command-line interface" "SSH, Azure CLI" {
                    terminalInstance = containerInstance flaskApp.terminal
                }
            }

            deploymentNode "Azure Cloud" "Microsoft Azure" "Azure IaaS" {
                deploymentNode "Virtual Network" "vnet-flask-dev (10.0.0.0/16)" "Azure VNet" {

                    deploymentNode "Default Subnet" "snet-default (10.0.0.0/24)" "Azure Subnet" {
                        nsgDefault = infrastructureNode "NSG Default" "Allow SSH, HTTP, HTTPS from Internet" "Azure NSG" {
                            tags "NSG"
                        }
                        deploymentNode "Application Server VM" "vm-app (Standard_B1s)" "Azure VM, Ubuntu 24.04 LTS" {
                            appServerInstance = containerInstance flaskApp.appServer
                        }
                    }
                }

                deploymentNode "PostgreSQL Service" "Azure PostgreSQL Flexible Server" "Burstable B1ms" {
                    databaseInstance = containerInstance flaskApp.database {
                        properties {
                            "Public Access" "Enabled (0.0.0.0 - 255.255.255.255)"
                            "SSL Mode" "Require"
                        }
                    }
                }
            }
        }
    }

    views {
        # C1 - System Context
        systemContext flaskApp "C1-Context" "System Context showing actors and the system" {
            include *
            autolayout lr
        }

        # C2 - Container (full view)
        container flaskApp "C2-Containers" "Container diagram showing technical building blocks" {
            include *
            exclude relationship.tag==ComponentLevel
        }

        # C3 - Component (Application Server)
        component flaskApp.appServer "C3-Components" "Component diagram showing Flask application internals" {
            include *
            include user
            include flaskApp.browser
            include flaskApp.database
        }

        # Deployment
        deployment flaskApp production "Deployment" "Simplified Azure deployment architecture" {
            include *
            exclude relationship.tag==ComponentLevel
        }

        styles {
            element "Person" {
                shape Person
                background #08427B
                color #ffffff
            }
            element "Primary Actor" {
                background #08427B
                color #ffffff
            }
            element "Secondary Actor" {
                background #5c5c5c
                color #ffffff
            }
            element "Software System" {
                background #438DD5
                color #ffffff
            }
            element "Container" {
                background #438DD5
                color #ffffff
            }
            element "Component" {
                background #85BBF0
                color #000000
            }
            element "Database" {
                shape Cylinder
                background #438DD5
                color #ffffff
            }
            element "Application" {
                background #438DD5
                color #ffffff
            }
            element "Client" {
                shape RoundedBox
                background #85BBF0
                color #000000
            }
            element "Primary Client" {
                shape RoundedBox
                background #08427B
                color #ffffff
            }
            element "Secondary Client" {
                shape RoundedBox
                background #5c5c5c
                color #ffffff
            }
            element "NSG" {
                background #ffffff
                color #cc0000
            }
        }

        theme default
    }

}
