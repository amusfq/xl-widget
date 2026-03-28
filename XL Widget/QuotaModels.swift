import Foundation

struct QuotaResponse: Codable {
    let success: Bool
    let code: String
    let message: String
    let data: QuotaData
}

struct QuotaData: Codable {
    let subs_info: SubsInfo
    let package_info: PackageInfo
    
    // Logic moved here: Find the primary quota
    var primaryQuota: Quota? {
        package_info.packages
            .flatMap { $0.quotas }
            .first { $0.name.contains("Kuota Utama") } 
            ?? package_info.packages.flatMap { $0.quotas }.first
    }
    
    // Logic moved here: Find the earliest expiry date
    var earliestExpiryDate: Date? {
        let formatter = DateUtils.sharedFormatter
        return package_info.packages
            .compactMap { formatter.date(from: $0.expiry) }
            .min()
    }
}

struct SubsInfo: Codable {
    let msisdn: String
    let operatorName: String
    let exp_date: String
    
    enum CodingKeys: String, CodingKey {
        case msisdn
        case operatorName = "operator"
        case exp_date
    }
}

struct PackageInfo: Codable {
    let packages: [Package]
}

struct Package: Codable {
    let name: String
    let expiry: String
    let quotas: [Quota]
}

struct Quota: Codable {
    let name: String
    let percent: Double
    let total: String
    let remaining: String
    
    // Helper to parse "4.6GB" or "200MB" into MegaBytes (Double)
    var remainingValueMB: Double {
        let numericPart = remaining.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
        guard let value = Double(numericPart) else { return 0 }
        
        if remaining.uppercased().contains("GB") {
            return value * 1024
        } else if remaining.uppercased().contains("MB") {
            return value
        } else if remaining.uppercased().contains("KB") {
            return value / 1024
        }
        return value
    }
}

// Global utility to reuse expensive formatters
enum DateUtils {
    static let sharedFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd-MM-yyyy"
        return df
    }()
}
