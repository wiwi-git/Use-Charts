import pymysql

class DBController:
    host = '127.0.0.1'
    port = 3306
    user = 'tutorial_user'
    pw = 'tutorial'
    db = 'tutorial'

    def __init__(self):
        print("__init__")
        self.conn = pymysql.connect(host=self.host, port=self.port, user=self.user, password=self.pw, db=self.db)
        self.curs = self.conn.cursor(pymysql.cursors.DictCursor)

    def create_connect(self, host=host, port=port, id=user, pw=pw, db_name=db):
        self.conn = pymysql.connect(host=host, port=port, user=id, password=pw, db=db_name)
        self.curs = self.conn.cursor(pymysql.cursors.DictCursor)

    def execute(self, query, args={}):
         self.curs.execute(query, args)

    def execute_one(self, query, args={}):
        self.curs.execute(query, args)

        row = self.curs.fetchone()
        return row

    def execute_all(self, query, args={}):
        self.curs.execute(query, args)
        row = self.curs.fetchall()
        return row

    def commit(self):
        self.conn.commit()