import db
import datetime
import random

db_controller = db.DBController()

def insert_count(date):
    query = "insert into views(date, count) values(%s, %s);"
    count = random.randint(0, 500)
    db_controller.execute(query, (date, count))


if __name__ == '__main__':
    temp_date = datetime.datetime(2020,1,1)
    for i in range(60):
        insert_count(temp_date)
        temp_date += datetime.timedelta(days=1)

    db_controller.commit()