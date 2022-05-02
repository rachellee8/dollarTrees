//
//  SummaryBudgetsViewController.swift
//  finalProject
//
//  Created by Rachel Lee on 4/25/22.
//

import SwiftUI
import Charts
import FirebaseAuthUI
import FirebaseGoogleAuthUI

//struct TransactionBarChartView: UIViewRepresentable {
//    let entries: [BarChartDataEntry]
//    func makeUIView(context: Context) -> BarChartView {
//        return BarChartView()
//    }
//
//    func updateUIView(_ uiView: BarChartView, context: Context) {
//        let dataSet = BarChartDataSet(entries: entries)
//        uiView.data = BarChartData(dataSet: dataSet)
//    }
//}

private let dateFormatter: DateFormatter = {
    print("📅 I JUST CREATED A DATE FORMATTER!")
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM yyyy"
    return dateFormatter
}()

class SummaryBudgetsViewController: UIViewController {
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var pieChartView: PieChartView!
    
    var boughtItems: BoughtItems!
    var loginViewController = LoginViewController()
    var authUI: FUIAuth!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        boughtItems = BoughtItems()
        
        authUI = FUIAuth.defaultAuthUI()
        authUI.delegate = loginViewController
        
        guard let currentUser = self.authUI.auth?.currentUser else {
            print("Couldn't get current user.")
            return
        }
        let budgetUser = BudgetUser(user: currentUser)
        
        boughtItems.loadData(user: budgetUser) {
            self.barChartView.backgroundColor = UIColor(named: "ChartBackground")
            self.customizeBarChart(dataPoints: self.boughtItems.itemsArray, values: self.boughtItems.itemsArray)
            
            let dateString = dateFormatter.string(from: Date())
            let dateList = dateString.split(separator: " ")
            let monthString = String(dateList[0])
            
            let itemTransactions = self.dataEntriesForMonth(monthString, boughtItems: self.boughtItems.itemsArray)
            
            self.pieChartView.backgroundColor = UIColor(named: "ChartBackground")
            self.customizePieChart(dataPoints: itemTransactions, values: itemTransactions)
        }
    }
    
    func dataEntriesForYear(_ year: String, boughtItems: [BoughtItem]) -> [BoughtItem] {
        let yearTransactions = boughtItems.filter{$0.date[2] == year}
        return yearTransactions
    }
    
    func customizeBarChart(dataPoints: [BoughtItem], values: [BoughtItem]) {
        var dataEntries: [BarChartDataEntry] = []
        
        let yearString = dateFormatter.string(from: Date())
        
        let lengthOfDate = yearString.count
        var year = ""
        var i = 0
        for character in yearString {
            if i + 5 > lengthOfDate {
                year += String(character)
            }
            i += 1
        }
        
        let itemTransactions = dataEntriesForYear(year, boughtItems: boughtItems.itemsArray)
        
        for i in 0...11 {
            var totalSpent: Double = 0.0
            for item in itemTransactions {
                if Int(item.date[0]) == i + 1 {
                    totalSpent += item.price
                }
            }
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(totalSpent))
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Bar Chart View")
        let chartData = BarChartData(dataSet: chartDataSet)
        barChartView.data = chartData
        chartDataSet.colors = colorsOfCharts(numbersOfColor: chartData.count)
        
        let monthList = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        
        
//        barChartView.delegate = self
        
        // Hightlight
        barChartView.highlightPerTapEnabled = true
        barChartView.highlightFullBarEnabled = true
        barChartView.highlightPerDragEnabled = false
        
        // disable zoom function
        barChartView.pinchZoomEnabled = false
        barChartView.setScaleEnabled(false)
        barChartView.doubleTapToZoomEnabled = false
        
        // Bar, Grid Line, Background
        barChartView.drawBarShadowEnabled = false
        barChartView.drawGridBackgroundEnabled = false
        barChartView.drawBordersEnabled = false
//        barChartView.borderColor = .chartLineColour
        
        // Legend
        barChartView.legend.enabled = false
        
        // Chart Offset
        barChartView.setExtraOffsets(left: 10, top: 0, right: 20, bottom: 50)
        
        // Animation
        barChartView.animate(yAxisDuration: 1.5 , easingOption: .easeOutBounce)
        
        // Setup X axis
        let xAxis = barChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawAxisLineEnabled = true
        xAxis.drawGridLinesEnabled = false
        xAxis.granularityEnabled = false
        xAxis.labelRotationAngle = -25
        xAxis.setLabelCount(12, force: false)
        xAxis.valueFormatter = IndexAxisValueFormatter(values: monthList)
//        xAxis.axisMaximum = Double()
//        xAxis.axisLineColor = .chartLineColour
        xAxis.labelTextColor = .black
        
        
        // Setup left axis
        let leftAxis = barChartView.leftAxis
        leftAxis.drawTopYLabelEntryEnabled = true
        leftAxis.drawAxisLineEnabled = true
        leftAxis.drawGridLinesEnabled = true
        leftAxis.granularityEnabled = false
//        leftAxis.axisLineColor = .chartLineColour
        leftAxis.labelTextColor = .black
        
//        leftAxis.setLabelCount(6, force: true)
        leftAxis.axisMinimum = 0.0
        
//        var totalSpentList: [Double] = []
        var maxTotalSpent = 0.0
        
        if itemTransactions.count == 0 {
            leftAxis.axisMaximum = 100.0
        } else {
            for i in 0...11 {
                var totalSpent: Double = 0.0
                for item in itemTransactions {
                    if Int(item.date[0]) == i + 1 {
                        totalSpent += item.price
                    }
                }
                if totalSpent > maxTotalSpent {
                    maxTotalSpent = totalSpent
                }
            }
            leftAxis.axisMaximum = maxTotalSpent + 100.0
        }
        
        // Remove right axis
        let rightAxis = barChartView.rightAxis
        rightAxis.enabled = false
        
        barChartView.barData?.setValueTextColor(.black)
        
        
        // customize bar chart axis
        
//        let monthList = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
//        barChartView.xAxis.axisMaxLabels = 12
//        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: monthList)
//        barChartView.xAxis.labelRotationAngle = -25
//
//        let rightAxis = barChartView.rightAxis
//        rightAxis.enabled = false
    }
    
    func dataEntriesForMonth (_ month: String, boughtItems: [BoughtItem]) -> [BoughtItem] {
        let monthDictionary = ["January" : "01", "February" : "02", "March" : "03", "April" : "04", "May" : "05", "June" : "06", "July" : "07", "August" : "08", "September" : "09", "October" : "10", "November" : "11", "December" : "12"]
        let monthTransactions = boughtItems.filter{$0.date[0] == monthDictionary[month]}
        return monthTransactions
    }
    
    func customizePieChart(dataPoints: [BoughtItem], values: [BoughtItem]) {
        
        // 1. Set ChartDataEntry
        var dataEntries: [ChartDataEntry] = []
        
        var categoryDictionary: [String : Double] = [:]
        
        for item in dataPoints {
            if categoryDictionary[item.category] == nil {
                categoryDictionary[item.category] = item.price
            } else {
                categoryDictionary[item.category] = categoryDictionary[item.category]! + item.price
            }
        }
        
//        for key, value in categoryDictionary.items() {
//            let dataEntry = PieChartDataEntry(value: categoryDictionary[i].price, label: dataPoints[i].category, data: dataPoints[i].category as AnyObject)
//        }
        
        for category in categoryDictionary.keys {
            let dataEntry = PieChartDataEntry(value: categoryDictionary[category]!, label: category, data: category as AnyObject)
            dataEntries.append(dataEntry)
        }
        
//        for i in 0..<dataPoints.count {
//            let dataEntry = PieChartDataEntry(value: dataPoints[i].price, label: dataPoints[i].category, data: dataPoints[i].category as AnyObject)
//            dataEntries.append(dataEntry)
//        }
        
        // 2. Set ChartDataSet
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: "")
        pieChartDataSet.colors = colorsOfCharts(numbersOfColor: dataPoints.count)
        pieChartView.holeColor = UIColor(named: "PrimaryColor")
        pieChartDataSet.entryLabelColor = .black
        
        // 3. Set ChartData
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        let format = NumberFormatter()
        format.numberStyle = .none
        let formatter = DefaultValueFormatter(formatter: format)
        pieChartData.setValueFormatter(formatter)
        pieChartView.legend.textColor = .black
        
        // 4. Assign it to the chart’s data
        pieChartView.data = pieChartData
        pieChartView.animate(yAxisDuration: 1.5)
        
        pieChartView.data?.setValueTextColor(.black)
    }
    
    private func colorsOfCharts(numbersOfColor: Int) -> [UIColor] {
        var colors: [UIColor] = []
        for _ in 0..<numbersOfColor {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        return colors
    }
}

