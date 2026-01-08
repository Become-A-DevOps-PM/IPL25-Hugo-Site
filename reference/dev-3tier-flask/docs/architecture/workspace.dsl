workspace "Flask Three-Tier Application" "C4 architecture model for a three-tier Flask application deployed on Azure" {

    !identifiers hierarchical

    configuration {
        scope softwaresystem
    }

    model {
        # Actors
        user = person "Application User" "Interacts with the demo application via web browser" {
            tags "Primary Actor"
        }
        developer = person "Developer" "Deploys and maintains the application" {
            tags "Secondary Actor"
        }

        # The Three-Tier System
        flaskApp = softwareSystem "Flask Three-Tier Application" "Demo application demonstrating presentation, application, and data tiers" {

            !docs docs
            !adrs adrs

            # ==================================================================
            # TIER 1: PRESENTATION TIER (Browser)
            # ==================================================================
            group "Tier 1: Presentation" {
                browser = container "Web Browser" "Renders HTML, handles user interaction, submits forms" "Chrome, Firefox, Safari, Edge" {
                    tags "Presentation Tier" "Client"

                    # What runs/renders in the browser
                    htmlPages = component "HTML Pages" "Rendered HTML documents from server" "HTML5"
                    cssStyles = component "CSS Stylesheet" "Visual styling and layout" "CSS3 (style.css)"
                    htmlForms = component "HTML Forms" "User input forms for data entry" "HTML Form Elements"
                    navigation = component "Navigation" "Links and page navigation" "HTML Anchors"
                }
            }

            # ==================================================================
            # TIER 2: APPLICATION TIER (Flask Server)
            # ==================================================================
            group "Tier 2: Application" {
                appServer = container "Application Server" "Handles HTTP requests, business logic, and page rendering" "Ubuntu 24.04, nginx, Python, Gunicorn" {
                    tags "Application Tier" "Server"

                    # Infrastructure Layer
                    nginx = component "nginx" "Reverse proxy, SSL termination, static file serving" "nginx"
                    gunicorn = component "Gunicorn" "WSGI server, process management" "Gunicorn (2 workers)"

                    # Flask Application Layer
                    flaskApp_internal = component "Flask App" "Application factory, configuration" "Flask create_app()"

                    # Routes Layer (Blueprints)
                    mainBlueprint = component "Main Blueprint" "Landing page route" "main_bp: GET /"
                    demoBlueprint = component "Demo Blueprint" "Demo form handling" "demo_bp: GET/POST /demo"
                    apiBlueprint = component "API Blueprint" "JSON API endpoints" "api_bp: GET /api/*"

                    # Business Logic Layer
                    entryService = component "Entry Service" "Business logic for entries" "EntryService class"

                    # Data Access Layer
                    entryModel = component "Entry Model" "ORM model for entries table" "SQLAlchemy Model"

                    # Template Layer
                    templates = component "Jinja2 Templates" "HTML page templates" "base.html, landing.html, demo.html"

                    # Static Files
                    staticFiles = component "Static Files" "CSS stylesheets" "static/css/style.css"
                }
            }

            # ==================================================================
            # TIER 3: DATA TIER (PostgreSQL)
            # ==================================================================
            group "Tier 3: Data" {
                database = container "PostgreSQL Database" "Persistent storage for application data" "Azure PostgreSQL Flexible Server" {
                    tags "Data Tier" "Database"

                    entriesTable = component "entries Table" "Stores entry records" "id, value, created_at"
                }
            }
        }

        # ==================================================================
        # RELATIONSHIPS - Context Level
        # ==================================================================
        user -> flaskApp "Uses demo application" "HTTPS"
        developer -> flaskApp "Deploys and monitors" "SSH, HTTPS"

        # ==================================================================
        # RELATIONSHIPS - Container Level (Tier-to-Tier)
        # ==================================================================
        user -> flaskApp.browser "Interacts with" "Mouse, keyboard"
        flaskApp.browser -> flaskApp.appServer "HTTP/HTTPS requests" "HTTPS/443"
        flaskApp.appServer -> flaskApp.database "Reads/writes data" "PostgreSQL/5432"

        # ==================================================================
        # RELATIONSHIPS - Component Level (Presentation Tier)
        # ==================================================================
        # Browser internal relationships
        flaskApp.browser.htmlForms -> flaskApp.browser.navigation "Form submission triggers" "HTTP POST"
        flaskApp.browser.htmlPages -> flaskApp.browser.cssStyles "Styled by" "CSS link"
        flaskApp.browser.htmlPages -> flaskApp.browser.navigation "Contains" "HTML anchors"
        flaskApp.browser.htmlPages -> flaskApp.browser.htmlForms "Contains" "HTML form"

        # Browser to Server
        flaskApp.browser.navigation -> flaskApp.appServer.nginx "GET requests" "HTTPS" {
            tags "Tier1to2"
        }
        flaskApp.browser.htmlForms -> flaskApp.appServer.nginx "POST form data" "HTTPS" {
            tags "Tier1to2"
        }

        # ==================================================================
        # RELATIONSHIPS - Component Level (Application Tier)
        # ==================================================================
        # Infrastructure flow
        flaskApp.appServer.nginx -> flaskApp.appServer.gunicorn "Proxy requests" "HTTP/5001"
        flaskApp.appServer.nginx -> flaskApp.appServer.staticFiles "Serves directly" "File I/O"
        flaskApp.appServer.gunicorn -> flaskApp.appServer.flaskApp_internal "WSGI calls" "Python"

        # Flask routing
        flaskApp.appServer.flaskApp_internal -> flaskApp.appServer.mainBlueprint "Routes /" "Blueprint"
        flaskApp.appServer.flaskApp_internal -> flaskApp.appServer.demoBlueprint "Routes /demo" "Blueprint"
        flaskApp.appServer.flaskApp_internal -> flaskApp.appServer.apiBlueprint "Routes /api" "Blueprint"

        # Blueprint to Service
        flaskApp.appServer.demoBlueprint -> flaskApp.appServer.entryService "CRUD operations" "Python"
        flaskApp.appServer.apiBlueprint -> flaskApp.appServer.entryService "Query entries" "Python"

        # Blueprint to Templates
        flaskApp.appServer.mainBlueprint -> flaskApp.appServer.templates "Renders landing.html" "Jinja2"
        flaskApp.appServer.demoBlueprint -> flaskApp.appServer.templates "Renders demo.html" "Jinja2"

        # Service to Model
        flaskApp.appServer.entryService -> flaskApp.appServer.entryModel "Uses" "Python"

        # Response flow back to browser
        flaskApp.appServer.templates -> flaskApp.browser.htmlPages "Returns HTML" "HTTP Response" {
            tags "Tier2to1"
        }
        flaskApp.appServer.staticFiles -> flaskApp.browser.cssStyles "Returns CSS" "HTTP Response" {
            tags "Tier2to1"
        }
        flaskApp.appServer.apiBlueprint -> flaskApp.browser "Returns JSON" "HTTP Response" {
            tags "Tier2to1"
        }

        # ==================================================================
        # RELATIONSHIPS - Component Level (Data Tier)
        # ==================================================================
        flaskApp.appServer.entryModel -> flaskApp.database.entriesTable "SQL queries" "psycopg2" {
            tags "Tier2to3"
        }

        # ==================================================================
        # DEPLOYMENT - Azure IaaS
        # ==================================================================
        production = deploymentEnvironment "Production" {
            deploymentNode "User Device" "End user's computer or mobile device" "Desktop/Laptop/Mobile" {
                deploymentNode "Web Browser" "Browser runtime environment" "Chrome, Firefox, Safari" {
                    tags "Presentation Tier"
                    browserInstance = containerInstance flaskApp.browser
                }
            }

            deploymentNode "Azure Cloud" "Microsoft Azure" "Azure IaaS" {
                deploymentNode "Virtual Network" "vnet-flask-dev (10.0.0.0/16)" "Azure VNet" {

                    deploymentNode "Default Subnet" "snet-default (10.0.0.0/24)" "Azure Subnet" {
                        appServerVM = deploymentNode "Application Server VM" "vm-app (Standard_B1s, Ubuntu 24.04)" "Azure VM" {
                            tags "Application Tier"
                            appServerInstance = containerInstance flaskApp.appServer
                        }

                        nsgDefault = infrastructureNode "NSG" "Allow SSH, HTTP, HTTPS" "Azure NSG" {
                            tags "NSG"
                        }

                        # NSG filters traffic to VM
                        nsgDefault -> appServerVM "Filters traffic"
                    }
                }

                deploymentNode "PostgreSQL Service" "psql-flask-dev" "Azure PostgreSQL Flexible Server, Burstable B1ms" {
                    tags "Data Tier"
                    databaseInstance = containerInstance flaskApp.database
                }
            }
        }
    }

    views {
        # C1 - System Context
        systemContext flaskApp "C1-Context" "System Context showing actors and the three-tier system" {
            include *
            autolayout lr
        }

        # C2 - Container (Three Tiers)
        container flaskApp "C2-Containers" "Container diagram showing the three tiers" {
            include *
            exclude relationship.tag==Tier1to2
            exclude relationship.tag==Tier2to1
            exclude relationship.tag==Tier2to3
        }

        # C3 - Component (Presentation Tier - Browser)
        component flaskApp.browser "C3-PresentationTier" "What renders and runs in the browser" {
            include *
            include user
            include flaskApp.appServer.nginx
            include flaskApp.appServer.templates
            include flaskApp.appServer.staticFiles
        }

        # C3 - Component (Application Tier - Flask Server)
        component flaskApp.appServer "C3-ApplicationTier" "Flask application server internals" {
            include *
            include flaskApp.browser
            include flaskApp.database
        }

        # C3 - Component (Data Tier - PostgreSQL)
        component flaskApp.database "C3-DataTier" "Database schema and tables" {
            include *
            include flaskApp.appServer.entryModel
        }

        # Deployment
        deployment flaskApp production "Deployment" "Azure deployment showing all three tiers" {
            include *
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
            # Tier-specific colors
            element "Presentation Tier" {
                background #2E86AB
                color #ffffff
            }
            element "Application Tier" {
                background #A23B72
                color #ffffff
            }
            element "Data Tier" {
                background #F18F01
                color #ffffff
            }
            element "Client" {
                shape WebBrowser
            }
            element "Database" {
                shape Cylinder
            }
            element "NSG" {
                background #ffffff
                color #cc0000
            }
        }

        theme default
    }

}
