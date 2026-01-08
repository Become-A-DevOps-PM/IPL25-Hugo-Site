workspace "Webinar Registration Website" "C4 architecture model for the webinar registration system deployed on Azure IaaS" {

    !identifiers hierarchical
    
    configuration {
        scope softwaresystem
    }

    model {
        # Actors
        attendee = person "Event Attendee" "Primary actor - registers for and attends webinars" {
            tags "Primary Actor"
            properties {
                "Actor Type" "Primary"
                "Frequency" "High"
                "Trust Level" "External, untrusted"
            }
            perspectives {
                "Business" "Main customer touchpoint, drives webinar attendance"
                "Security" "External user, requires input validation"
            }
        }
        admin = person "Marketing Admin" "Supporting actor - manages webinars and views registrations" {
            tags "Primary Actor"
            properties {
                "Actor Type" "Secondary"
                "Frequency" "Medium"
                "Trust Level" "Internal, trusted"
            }
            perspectives {
                "Business" "Monitors registration success, plans capacity"
                "Security" "Internal user, future: requires authentication"
            }
        }
        sysadmin = person "SysAdmin" "Supporting actor - deploys and maintains infrastructure" {
            tags "Secondary Actor"
            properties {
                "Actor Type" "Secondary"
                "Frequency" "Low"
                "Trust Level" "Internal, privileged"
            }
            perspectives {
                "Business" "Ensures system availability and performance"
                "Security" "Privileged access via SSH through bastion host"
            }
        }

        # The System
        webinarSystem = softwareSystem "Webinar Registration Website" "Allows attendees to register for webinars and administrators to manage events" {
            
            !docs docs
            !adrs adrs
            
            # Client-side Containers
            group "Front-end" {
                browser = container "Web Browser" "Renders HTML, JavaScript and CSS" "Chrome, Firefox, Safari" {
                    tags "Client" "Primary Client"
                }
                
                terminal = container "Terminal" "Command-line interface for administrative access" "Azure CLI, SSH" {
                    tags "Client" "Secondary Client"
                }
            }
            
            # Server-side Containers
            group "Back-end" {
                bastion = container "Bastion Host" "Secure SSH entry point for administrative access" "Ubuntu 24.04, Fail2ban" {
                    tags "Bastion"
                }
                
                proxy = container "Reverse Proxy" "SSL offloading and request forwarding" "nginx, OpenSSL" {
                    # Components
                    httpRedirect = component "HTTP Redirect Block" "Redirects HTTP to HTTPS" "nginx server block port 80"
                    httpsServerBlock = component "HTTPS Server Block" "SSL termination and request handling" "nginx server block port 443"
                    sslCertificate = component "SSL Certificate" "TLS/SSL certificate for encryption" "Self-signed (OpenSSL)"
                }
                
                flask = container "Flask Application" "Handles registration logic, serves HTML" "Python/Gunicorn" {
                    tags "Application"
                    
                    # Components
                    routes = component "Route Handlers" "HTTP request handling, form processing" "Flask @app.route"
                    templates = component "Template Engine" "HTML rendering with data binding" "Jinja2"
                    models = component "Data Models" "Database abstraction, ORM" "SQLAlchemy"
                    wsgi = component "WSGI Server" "Production HTTP server, process management" "Gunicorn"
                }
                
                database = container "PostgreSQL Database" "Stores registration data persistently" "Managed PostgreSQL" {
                    tags "Database"
                }
            }
        }

        # Relationships - Context Level
        attendee -> webinarSystem "Registers for webinars" "HTTPS"
        admin -> webinarSystem "Views registrations" "HTTPS"
        sysadmin -> webinarSystem "Deploys and maintains" "SSH"

        # Relationships - Container Level
        attendee -> webinarSystem.browser "Uses" "Mouse, keyboard"
        admin -> webinarSystem.browser "Uses" "Mouse, keyboard"
        sysadmin -> webinarSystem.terminal "Uses" "Keyboard"
        
        webinarSystem.browser -> webinarSystem.proxy "HTTPS requests" "HTTPS/443"
        webinarSystem.terminal -> webinarSystem.bastion "Connects to" "Azure CLI, SSH"

        webinarSystem.bastion -> webinarSystem.proxy "SSH" "SSH/22"
        webinarSystem.bastion -> webinarSystem.flask "SSH" "SSH/22"
        webinarSystem.proxy -> webinarSystem.flask "Forwards requests" "HTTP/5001"
        webinarSystem.flask -> webinarSystem.database "Reads/writes data" "PostgreSQL/5432"

        # Relationships - Component Level (Flask)
        webinarSystem.proxy -> webinarSystem.flask.wsgi "HTTP requests" "HTTP/5001"
        webinarSystem.flask.wsgi -> webinarSystem.flask.routes "Forwards requests" "WSGI"
        webinarSystem.flask.routes -> webinarSystem.flask.templates "Renders HTML" "Jinja2 API"
        webinarSystem.flask.routes -> webinarSystem.flask.models "CRUD operations" "Python method calls"
        webinarSystem.flask.models -> webinarSystem.database "SQL queries" "psycopg2"
        webinarSystem.flask.templates -> webinarSystem.browser "Returns HTML" "HTTP Response" {
            tags "FlaskComponent"
        }

        # Relationships - Component Level (Proxy)
        webinarSystem.browser -> webinarSystem.proxy.httpRedirect "HTTP request" "HTTP/80" {
            tags "ComponentLevel"
        }
        webinarSystem.proxy.httpRedirect -> webinarSystem.browser "301 Redirect to HTTPS" "HTTP Response" {
            tags "ComponentLevel"
        }
        webinarSystem.browser -> webinarSystem.proxy.httpsServerBlock "HTTPS request" "HTTPS/443" {
            tags "ComponentLevel"
        }
        webinarSystem.proxy.httpsServerBlock -> webinarSystem.proxy.sslCertificate "Uses" "TLS"
        webinarSystem.proxy.httpsServerBlock -> webinarSystem.flask "Forwards to backend" "HTTP/5001"

        # Deployment - Azure IaaS
        production = deploymentEnvironment "Production" {
            deploymentNode "User Environment" "User's local machine" "Desktop/Laptop" {
                deploymentNode "Web Browser" "User's web browser for accessing the application" "Chrome, Firefox, Safari" {
                    browserInstance = containerInstance webinarSystem.browser
                }
                deploymentNode "Terminal" "Command-line interface for administrative tasks" "Azure CLI, SSH" {
                    terminalInstance = containerInstance webinarSystem.terminal
                }
            }
            
            deploymentNode "Azure Cloud" "Microsoft Azure public cloud infrastructure" "Azure IaaS" {
                deploymentNode "Virtual Network" "vnet-flask-bicep-dev" "10.0.0.0/16" {
                    
                    deploymentNode "Bastion Subnet" "snet-bastion" "10.0.1.0/24" {
                        nsgBastion = infrastructureNode "NSG Bastion" "Allow SSH from Internet" "Azure NSG" {
                            tags "NSG"
                        }
                        deploymentNode "Bastion Host" "SSH jump server for secure admin access" "Azure VM, Ubuntu 24.04 LTS, Standard_B1s" {
                            bastionInstance = containerInstance webinarSystem.bastion
                        }
                    }

                    deploymentNode "Web Subnet" "snet-web" "10.0.2.0/24" {
                        nsgWeb = infrastructureNode "NSG Web" "Allow HTTP/HTTPS from Internet" "Azure NSG" {
                            tags "NSG"
                        }
                        deploymentNode "Reverse Proxy" "nginx server for SSL termination" "Azure VM, Ubuntu 24.04 LTS, Standard_B1s" {
                            proxyInstance = containerInstance webinarSystem.proxy
                        }
                    }

                    deploymentNode "App Subnet" "snet-app" "10.0.3.0/24" {
                        nsgApp = infrastructureNode "NSG App" "Allow HTTP from Web Subnet" "Azure NSG" {
                            tags "NSG"
                        }
                        deploymentNode "Application Server" "Flask application with Gunicorn" "Azure VM, Ubuntu 24.04 LTS, Standard_B1s" {
                            flaskInstance = containerInstance webinarSystem.flask
                        }
                    }

                    deploymentNode "Data Subnet" "snet-data" "10.0.4.0/24" {
                        nsgData = infrastructureNode "NSG Data" "Allow PostgreSQL from App Subnet" "Azure NSG" {
                            tags "NSG"
                        }
                        deploymentNode "Azure PostgreSQL Flexible Server" "psql-flask-bicep-dev" "Burstable B1ms" {
                            databaseInstance = containerInstance webinarSystem.database
                        }
                    }
                }
            }
        }
    }

    views {
        # C1 - System Context
        systemContext webinarSystem "C1-Context" "System Context diagram showing actors and the system" {
            include *
            autolayout lr
        }

        # C2 - Container (full view with all actors)
        container webinarSystem "C2-Containers-Full" "Container diagram showing the complete system" {
            include *
            exclude relationship.tag==ComponentLevel
            exclude relationship.tag==FlaskComponent
        }

        # C3 - Component (Flask Application)
        component webinarSystem.flask "C3-Components" "Component diagram showing Flask application internals" {
            include *
            include attendee
            include webinarSystem.browser
            include webinarSystem.proxy
        }

        # C3 - Component (Reverse Proxy zoom)
        component webinarSystem.proxy "C3-Components-Proxy" "Component diagram showing nginx internals" {
            include *
            include attendee
            include webinarSystem.browser
            include webinarSystem.flask
            include webinarSystem.database
            exclude relationship.tag==FlaskComponent
        }

        # Deployment
        deployment webinarSystem production "Deployment" "Azure IaaS deployment architecture" {
            include *
            exclude relationship.tag==FlaskComponent
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
            element "Tertiary Actor" {
                background #85BBF0
                color #000000
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
            element "Bastion" {
                background #999999
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
