import oracledb

def init_db(app):
    connection = oracledb.connect(
        user=app.config['ORACLE_USER'],
        password=app.config['ORACLE_PASSWORD'],
        dsn=app.config['ORACLE_DSN']
    )
    app.oracle_connection = connection
