import Foundation

// #7 검색 API 응답 모델 — 명세: docs/slice-7/design.md (OpenAPI)
struct SearchResponse: Codable, Equatable {
    let count: Int
    let results: [BuildingResult]
    let reasonCode: String?

    enum CodingKeys: String, CodingKey {
        case count, results
        case reasonCode = "reason_code"
    }
}

struct BuildingResult: Codable, Equatable, Identifiable {
    let id: Int
    let name: String
    let matchedAlias: String?
    let distanceM: Double

    enum CodingKeys: String, CodingKey {
        case id, name
        case matchedAlias = "matched_alias"
        case distanceM = "distance_m"
    }
}

struct APIErrorBody: Codable, Equatable {
    let errorCode: String
    let message: String

    enum CodingKeys: String, CodingKey {
        case errorCode = "error_code"
        case message
    }
}

enum SearchError: Error, Equatable {
    case badRequest(code: String, message: String)
    case network(String)
}
