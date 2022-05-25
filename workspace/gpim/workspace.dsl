/*
 * This is a combined version of the following workspaces:
 *
 * - "Big Bank plc - System Landscape" (https://structurizr.com/share/28201/)
 * - "Big Bank plc - Internet Banking System" (https://structurizr.com/share/36141/)
*/
workspace "GPIM 業務流程" "這是簡介" {

    model {
        customer = person "客戶" "購買產品之客戶" "Customer"

        enterprise "GPIM 系統" {
            deviceOwner1 = person "裝置配戴者1" "" "Device Owner"
            deviceOwner2 = person "裝置配戴者2" "" "Device Owner"
            deviceOwner3 = person "裝置配戴者3" "" "Device Owner"

            GPIMDataSystem = softwaresystem "GPIM 資料傳輸系統" "資料傳輸網路" {
              iotSystem = container "Iot" "韌體" {
                thingsboardGateway = component "thingsboard-gateway" "多通訊協議輸入轉發MQTT" "Iot"
                mqttBorker = component "MQTT Borker" "接收 Topic 轉發給訂閱者" "Iot"
              }

              ELKSystem = container "ELK" "全文檢索系統" {
                filebeat = component "Filebeat" "收集資料、資料Filter" "ELK"
                elasticsearch = component "Elasticsearch" "數據中臺\nport: 9200, 9300" "ELK"
                kibana = component "Kibana" "開發者圖形化介面\nport: 5601" "ELK"
              }
            }
            GPIMWebSystem = softwaresystem "GPIM 網站" "網站" {

              WebApp = container "SPA網站" "電腦網頁" "Vue" "Web Browser"
              IOSApp = container "IOS App" "蘋果手機" "App" "Mobile App"
              AndroidApp = container "Android App" "安卓手機" "App" "Mobile App"
              frontend = container "前端" "Vue/React"

              backend = container "後端" "Django"
              database = container "Database" "Postgresql" "RMDB" "Database"

              WebApp -> frontend "Https" "Protocol"
              IOSApp -> frontend "Https" "Protocol"
              AndroidApp -> frontend "Https" "Protocol"
              backend -> database "Transaction" "Data"
              database -> backend "Transaction" "Data"
              backend -> elasticsearch "Transaction" "Data"
              elasticsearch -> backend "Transaction" "Data"
            }
        }

        live = deploymentEnvironment "Live" {

            deploymentNode "Amazon Web Services" {
                tags "Amazon Web Services - Cloud"

                region = deploymentNode "US-East-1" {
                    tags "Amazon Web Services - Region"

                    route53 = infrastructureNode "Route 53" {
                        description "Amazon Web Services - Route 53"
                        tags "Amazon Web Services - Route 53"
                    }

                    elb = infrastructureNode "Elastic Load Balancer" {
                        description "Automatically distributes incoming application traffic."
                        tags "Amazon Web Services - Elastic Load Balancing"
                    }

                    deploymentNode "Autoscaling group" {
                        tags "Amazon Web Services - Auto Scaling"

                        deploymentNode "Amazon EC2" {
                            tags "Amazon Web Services - EC2"
                            webApplicationInstance = containerInstance backend
                        }
                    }

                }
            }

            route53 -> elb "Forwards requests to" "HTTPS"
            elb -> webApplicationInstance "Forwards requests to" "HTTPS"
        }

        # relationships between people and software systems
        customer -> deviceOwner1 "分配裝置" "Device"
        customer -> deviceOwner2 "分配裝置" "Device"
        customer -> deviceOwner3 "分配裝置" "Device"

        # relationships to/from containers
        deviceOwner1 -> iotSystem "MQTT" "Protocol"
        deviceOwner2 -> iotSystem "Https" "Protocol"
        deviceOwner3 -> iotSystem "NB-IOT" "Protocol"

        # relationships to/from components
        customer -> WebApp "裝置" "Device"
        customer -> IOSApp "裝置" "Device"
        customer -> AndroidApp "裝置" "Device"
        thingsboardGateway -> mqttBorker "Port 1884" "Protocol"
        mqttBorker -> filebeat "MQTT: port 1884" "ELK"
        filebeat -> elasticsearch "port 9200" "ELK"
        elasticsearch -> kibana "port 9300" "ELK"
        frontend -> backend "Https" "Protocol"

    }

    views {
        deployment GPIMWebSystem "Live" "AmazonWebServicesDeployment" {
            include *
            autolayout lr

            animation {
                route53
                elb
                webApplicationInstance
            }
        }

        # View for Systemlandscape
        systemlandscape "Systemlandscape" {
            include *
            autoLayout
        }

        # View for Container
        container GPIMDataSystem "GPIMData" {
            include *
            animation {
                deviceOwner1 deviceOwner2 deviceOwner3
                iotSystem
                ELKSystem
            }
            autoLayout
        }

        container GPIMWebSystem "GPIMWeb" {
            include *
            animation {
                customer
                backend
                frontend
            }
            autoLayout
        }

        # View for Component
        component iotSystem "IOT" {
            include *
            animation {
                thingsboardGateway
                mqttBorker
            }
            autoLayout
        }

        component ELKSystem "ELK" {
            include *
            animation {
                filebeat
            }
            autoLayout
        }


        styles {
            element "Person" {
                color #ffffff
                fontSize 22
                shape Person
            }
            element "Customer" {
                background #08427b
            }
            element "Device Owner" {
                background #44b3d5
            }
            element "Software System" {
                background #1168bd
                color #ffffff
            }
            element "Container" {
                background #438dd5
                color #ffffff
            }
            element "Web Browser" {
                shape WebBrowser
            }
            element "Mobile App" {
                shape MobileDeviceLandscape
            }
            element "Database" {
                shape Cylinder
            }
            element "Component" {
                background #85bbf0
                color #000000
            }
            element "Failover" {
                opacity 25
            }
        }
    }
}
