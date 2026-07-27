import Foundation

protocol SearchServicing {
    func search(query: String, lat: Double, lng: Double) async throws -> SearchResponse
}

// #7 검색 API 클라이언트. 기본 주소는 로컬 개발 서버(server/src/server.js).
// ATS는 루프백(127.0.0.1)을 기본 허용하므로 예외 설정 불필요.
struct SearchService: SearchServicing {
    var baseURL = URL(string: "http://127.0.0.1:3000")!
    var session: URLSession = .shared

    func search(query: String, lat: Double, lng: Double) async throws -> SearchResponse {
        var comps = URLComponents(url: baseURL.appendingPathComponent("api/buildings/search"),
                                  resolvingAgainstBaseURL: false)!
        comps.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lng", value: String(lng)),
        ]
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(from: comps.url!)
        } catch {
            throw SearchError.network(error.localizedDescription)
        }
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        let decoder = JSONDecoder()
        if status == 200 {
            do { return try decoder.decode(SearchResponse.self, from: data) }
            catch { throw SearchError.network("응답 해석 실패") }
        }
        if let body = try? decoder.decode(APIErrorBody.self, from: data) {
            throw SearchError.badRequest(code: body.errorCode, message: body.message)
        }
        throw SearchError.network("서버 오류 (status \(status))")
    }
}
