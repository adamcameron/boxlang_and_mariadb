component {

    setsettings()
    loadDatasources()
    loadMappings()

    private void function setSettings() {
        this.name = "app1"
    }

    private void function loadDataSources() {
        this.datasources["dsn1"] = {
            driver = "mysql",
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

        this.datasource = "dsn1"
    }

    private void function loadMappings() {
    }
}
