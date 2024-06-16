import cx_Oracle

def init_db(app):
    dsn = cx_Oracle.makedsn(
        host=app.config['ORACLE_DSN'].split('/')[0].split(':')[0],
        port=app.config['ORACLE_DSN'].split('/')[0].split(':')[1],
        service_name=app.config['ORACLE_DSN'].split('/')[1]
    )
    app.oracle_connection = cx_Oracle.connect(
        user=app.config['ORACLE_USER'],
        password=app.config['ORACLE_PASSWORD'],
        dsn=dsn
    )
