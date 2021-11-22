import HealthKit

// Requests authorization and executes query
func executeActivitySummariesQuery(startDate: Date, endDate: Date, queryCallback: @escaping (HKQuery?, [HKActivitySummary]?, Error?) -> Void) {
    
    let healthStore = HKHealthStore()
    
    func createPredicate(startDate:Date, endDate:Date) -> NSPredicate {
        let calendar = NSCalendar.current
        let units: Set<Calendar.Component> = [.day, .month, .year, .era]
        var startDateComponents = calendar.dateComponents(units, from: startDate)
        var endDateComponents   = calendar.dateComponents(units, from: endDate)
        
        startDateComponents.calendar = calendar
        endDateComponents.calendar = calendar

        return HKQuery.predicate(forActivitySummariesBetweenStart: startDateComponents, end: endDateComponents)
    }
    
    healthStore.requestAuthorization(toShare: nil, read: [.activitySummaryType()]) { (success, error) -> Void in
        if(success){
            let predicate = createPredicate(startDate: startDate, endDate: endDate)
            let query = HKActivitySummaryQuery(predicate:predicate, resultsHandler: queryCallback)
            healthStore.execute(query)
        }else{
            print(error ?? "Unable to get activity summaries")
        }
    }
}



// Usage example
func printThisWeekActivitySummaries(){
    let calendar = NSCalendar.current
    guard let startDate = calendar.date(byAdding: .day, value: -7, to: Date()) else{
        fatalError("Cannot get start date")
    }
    executeActivitySummariesQuery(startDate: startDate, endDate: Date()) { (query, summaries, error) -> Void in
        guard let summaries = summaries else {
            print("No summaries found")
            return
        }
        for summary in summaries {
            print(summary)
        }
    }
}
