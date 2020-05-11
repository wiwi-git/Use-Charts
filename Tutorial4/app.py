from flask import Flask, jsonify
from flask_restful import Api, Resource, reqparse
import db
import datetime

app = Flask(__name__)
api = Api(app)
db_controller = db.DBController()

class GetPageViewInfo(Resource):
    def get(self):
        return {'result': 'fail', 'error': 'Invalid Access.'}

    def post(self):
        parser = reqparse.RequestParser()
        parser.add_argument('year', type=int)
        parser.add_argument('month', type=int)
        parser.add_argument('tz', type=int)

        args = parser.parse_args()

        _year = args['year']
        _month = args['month']
        _tz = args['tz']

        searched = self.search_data(year=_year, month=_month, time_difference=_tz)
        return_json = {
            'result': 'success',
            'error': None,
            'searched': searched
        }

        return jsonify(return_json)

    def search_data(self, year, month, time_difference):
        try:
            print("search keywrod : ",year," - ",month)

            next_year = year

            if (month + 1) > 12:
                next_month = 1
                next_year += 1
            else:
                next_month = month + 1

            _tz_value = datetime.timezone(datetime.timedelta(hours=time_difference))

            next_month_date = datetime.datetime(next_year, next_month, 1, tzinfo=_tz_value)
            target_first_date = datetime.datetime(year, month, 1, tzinfo=_tz_value)
            target_last_date = next_month_date - datetime.timedelta(days=1)

            query = "select date, count from views where date between %s and %s;"
            result = db_controller.execute_all(query, (target_first_date, target_last_date))

            data_list = []
            if len(result) == 0 :
                print("error search_data count is 0")
            else:
                for item in result:
                    dic = dict(item)
                    date = dic['date']
                    dic['date_str'] = str(date)
                    data_list.append(dic)
            return data_list

        except Exception as e:
            print("error search_data ", e)
            return []


class BlogInfo(Resource):
    def get(self):
        data = {
            'result': 'success',
            'name': 'wiwi_blog',
            'link': 'wiwi-pe.tistory.com',
            'des': 'tStory blog',
        }
        return jsonify(data)

    def post(self):
        return {'result': 'fail', 'error': 'Invalid Access.'}


api.add_resource(GetPageViewInfo, '/api/get-views')
api.add_resource(BlogInfo, '/api/blog-info')


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
