//
//  MainVC.swift
//  Tutorial4
//
//  Created by 위대연 on 2020/05/06.
//  Copyright © 2020 위대연. All rights reserved.
//

import UIKit
import Charts


class MainVC: UIViewController {
    @IBOutlet weak var chartView:LineChartView!
    @IBOutlet weak var dateTextField:UITextField!
    @IBOutlet weak var totalLabel:UILabel!
    @IBOutlet weak var searchButton:UIButton!
    
    @IBOutlet weak var dateInputView: UIView!
    
    @IBOutlet weak var activitiIndicatorView: UIActivityIndicatorView!
    
    var daysChartLabel = Array<String>()
    var alertControl = UIAlertController()
    var calendar = Calendar(identifier: .gregorian)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.chartBasicSetting()
        
        self.dateInputView.layer.borderWidth = 1
        self.dateInputView.layer.borderColor = UIColor.black.cgColor
        self.dateInputView.layer.cornerRadius = 10
        
        self.dateTextField.delegate = self
        
        let datePicker = UIDatePicker()
        datePicker.calendar = .current
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(valueChangedDatePicker), for: .valueChanged)
        self.dateTextField.inputView = datePicker
        
        let toolbar = UIToolbar()
        toolbar.isUserInteractionEnabled = true
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.touchUpSearchButton(_:)))
        let place = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.closeKeyboard))
        
        toolbar.setItems([done,place,cancel], animated: false)
        toolbar.sizeToFit()
        
        self.dateTextField.inputAccessoryView = toolbar
        
        
        self.searchButton.addTarget(self, action: #selector(self.touchUpSearchButton(_:)), for: .touchUpInside)
        
        self.activitiIndicatorView.stopAnimating()
        self.activitiIndicatorView.isHidden = true
    }
    
    func chartBasicSetting(){
        self.chartView.delegate = self
        self.chartView.scaleYEnabled = false
        
        let xAxis = self.chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.valueFormatter = self
    
        chartView.leftAxis.axisMaximum = 500
        chartView.leftAxis.axisMinimum = 0
        
        chartView.rightAxis.enabled = false
        chartView.data = ChartData()
    }
    
    func setTwoPlace(monthOrDay:Int) -> String {
        return "\(monthOrDay)".count == 1 ? "0\(monthOrDay)" : "\(monthOrDay)"
    }
    
    /**
     Net 클래스에서 해당 월의 일자별 조회수데이터를 가져오는 함수 getViews의 값을 요청하고 받는 함수
     파라미터는 현지시간으로 받는다, - timezone + 값을 넣어서 보내기로 변경
     - Parameters :
     - year :Int (currentTimeZone)
     - month :Int (currentTimeZone)
     - day :Int (currentTimeZone)
     */
    func chartChageData(year:Int, month:Int, day:Int) {
        self.activitiIndicatorView.startAnimating()
        self.activitiIndicatorView.isHidden = false
        self.chartView.data = nil
        
        //// ==== current Time zone
        let yearString = "\(year)"
        let monthString = self.setTwoPlace(monthOrDay: month)
        let dayString = self.setTwoPlace(monthOrDay: day)
        
        guard yearString.count == 4, monthString.count == 2, dayString.count == 2 else {
            print("Error, MainVC chartInputdata, \(yearString.count) ? 4, \(monthString.count) ? 2,\(dayString.count) ? 2")
            return
        }
        
        let dateFormater = DateFormatter()
        dateFormater.timeZone = .current
        dateFormater.dateFormat = "yyyy-MM-dd"
        let targetDate:Date = dateFormater.date(from: "\(yearString)-\(monthString)-\(dayString)")!
        print("string date \(yearString)-\(monthString)-\(dayString), trans date \(targetDate)")
        self.calendar.timeZone = .current
        let daysOfMonth = (self.calendar.range(of: .day, in: .month, for: targetDate))!.count
        
        let placeSet = LineChartDataSet(entries: [ChartDataEntry()], label: nil)
        self.daysChartLabel.removeAll()
        
        for i in 0 ... daysOfMonth {
            let entry = ChartDataEntry(x: Double(i), y: 0)
            placeSet.append(entry)
            let day = i != daysOfMonth ? setTwoPlace(monthOrDay: i + 1) : "end"
            self.daysChartLabel.append("\(monthString)-\(day)")
        }

        /*
        /////----- utc
        dateFormater.timeZone = NSTimeZone.init(name: "UTC") as TimeZone?
        dateFormater.dateFormat = "yyyy-MM-dd"
        
        cal.timeZone = TimeZone.init(identifier: "UTC")!
        
        let dateComponents = cal.dateComponents([.year,.month], from: targetDate)
        let utcYear:Int = dateComponents.year!
        let utcMonth:Int = dateComponents.month!
        */
            /// chart create data
        let net = Net.sheared
        let realDataSet = LineChartDataSet(entries: [ChartDataEntry()], label: "\(yearString)-\(monthString)")
//        net.getViews(year: utcYear, month: utcMonth) { (views) in
        net.getViews(year: year, month: month) { (views) in
            print("getViews count:\(views.count)")
            var totalCount:Int = 0
            for item in views {
                if let date = dateFormater.date(from: item.date) {
                    let day = self.calendar.component(.day, from: date)
                    let entry = ChartDataEntry(x: Double(day), y: Double(item.count))
                    totalCount += item.count
                    realDataSet.append(entry)
                }
            }
            print("realDataSet.count : \(realDataSet.count)")
            
            placeSet.drawCirclesEnabled = false
            placeSet.drawValuesEnabled = false
            placeSet.lineWidth = 0
            placeSet.setColor(.clear)
            
            realDataSet.drawCirclesEnabled = true
            realDataSet.mode = .cubicBezier
            realDataSet.circleRadius = 3
            realDataSet.setCircleColor(.black)
            realDataSet.lineWidth = 1
            realDataSet.drawValuesEnabled = false
            realDataSet.setColor(NSUIColor(red: 0.8, green: 0.6, blue: 0.8, alpha: 1))
            
            self.totalLabel.text = "TOTAL : \(totalCount)"
            self.chartView.data = LineChartData(dataSets: [placeSet,realDataSet])
            
            self.chartView.notifyDataSetChanged()
            
            self.activitiIndicatorView.stopAnimating()
            self.activitiIndicatorView.isHidden = true
            
            self.searchButton.isEnabled = true
        }//Net.getViews
    }
    
    func showAlert(title:String,message:String,actions:[UIAlertAction]?) {
        self.alertControl = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if actions != nil {
            for action in actions! {
                self.alertControl.addAction(action)
            }
        } else {
            self.alertControl.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        }
        
        self.present(self.alertControl, animated: true, completion: nil)
    }
    @objc func closeKeyboard() {
        self.dateTextField.endEditing(true)
    }
    @objc func touchUpSearchButton(_ sender: UIButton) {
        self.dateTextField.endEditing(true)
        
        let targetText = self.dateTextField.text ?? ""
        let split = targetText.split(separator: "-")
        if split.count == 3 {
            let yearString = split[0]
            let monthString = split[1]
            let dayString = split[2]
            guard yearString.count == 4, monthString.count == 2, dayString.count == 2 else {
                self.showAlert(title: "Error", message: "날짜형식을 맞춰주세요", actions: nil)
                return
            }
            if let year = Int(yearString), let month = Int(monthString), let day = Int(dayString) {
                self.searchButton.isEnabled = false
                self.chartChageData(year: year, month: month, day: day)
            } else {
                print("Error MainVc- touchup search button, 잘못된 텍스트를 요청중 \(targetText)")
                self.showAlert(title: "Error", message: "날짜형식을 맞춰주세요", actions: nil)
            }
        } else {
            print("Error MainVc- touchup search button, 잘못된 텍스트를 요청중 \(split.count)")
            self.showAlert(title: "Error", message: "날짜형식을 맞춰주세요", actions: nil)
        }
    }
    
    @objc func valueChangedDatePicker(_ sender:UIDatePicker) {
        let selectedDate = sender.date
        self.calendar.timeZone = .current
        let components = self.calendar.dateComponents([.year,.month,.day], from: selectedDate)
        if let year = components.year, let month = components.month, let day = components.day {
            DispatchQueue.main.async {
                self.dateTextField.text = "\(year)-\(self.setTwoPlace(monthOrDay: month))-\(self.setTwoPlace(monthOrDay: day))"
            }
        } else {
            print("Error, MainVC valueChagedDatePIcker 날짜 변환 오류")
            self.dateTextField.text = ""
        }
    }
    
}

extension MainVC : ChartViewDelegate,IAxisValueFormatter,UITextFieldDelegate {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let _value:Int = Int(value)
        
        if  _value < self.daysChartLabel.count {
            return self.daysChartLabel[_value]
        }
        else {
            print("Error, MainVC IAxisValueFormatter-stringForValue labelCount over")
            return ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
    }
}
