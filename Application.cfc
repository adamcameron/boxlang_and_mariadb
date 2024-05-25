component {

    setsettings()
    loadDatasources()
    loadMappings()

    private void function setSettings() {
        this.name = "app1_#createUuid()#"
        //this.localMode = "modern"
    }

    private void function loadDataSources() {
        this.datasources["dsn1"] = {
            driver = "mysql",
            properties = {
                host = "database.backend",
                port = 3306,
                database = server.system.environment.MARIADB_DATABASE,
                username = server.system.environment.MARIADB_USER,
                password = server.system.environment.MARIADB_PASSWORD,
                custom = {
                    useUnicode = true,
                    characterEncoding = "UTF-8",
                    noAccessToProcedureBodies = true
                }
            }
        }

        this.datasource = "dsn1"
    }

    private void function loadMappings() {
    }
}
