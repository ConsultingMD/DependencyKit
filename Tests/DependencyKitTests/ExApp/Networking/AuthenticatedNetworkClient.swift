import Combine
import Foundation

struct ProfileInfoResponse: Codable {
    let email: String
}
struct LogoutResponse: Codable {}

protocol AuthenticatedNetworkClient {
    init(token: String, url: URL, appVersion: String, cache: NetworkCache)
    func fetchProfileInfo() -> AnyPublisher<ProfileInfoResponse, Error>
    func logout() -> AnyPublisher<LogoutResponse, Error>
}

final class AuthenticatedNetworkClientImpl: AuthenticatedNetworkClient {

    private let url: URL
    private let appVersion: String
    private let networkCache: NetworkCache

    init(token: String, url: URL, appVersion: String, cache: NetworkCache) {
        self.url = url
        self.appVersion = appVersion
        self.networkCache = cache
    }


    func fetchProfileInfo() -> AnyPublisher<ProfileInfoResponse, Error> {
        /*
        let profileUrl = url.appendingPathComponent("profile")
        if let data = networkCache.fetchResult(for: profileUrl),
           let model = try? JSONDecoder().decode(ProfileInfoResponse.self, from: data) {
            return Just(model)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        var profileRequest = URLRequest(url: profileUrl)
        profileRequest.addValue(appVersion, forHTTPHeaderField: "app-version")
        profileRequest.addValue("ios", forHTTPHeaderField: "platform")
        return URLSession.shared
            .dataTaskPublisher(for: profileRequest)
            .map { $0.data }
            .handleEvents(receiveOutput: { [networkCache] response in
                networkCache.save(result: response, for: profileUrl)
            })
            .decode(type: ProfileInfoResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
         */

        return Just(ProfileInfoResponse(email: "user@example.com"))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()

    }

    func logout() -> AnyPublisher<LogoutResponse, Error> {
        /*
        var logoutRequest = URLRequest(url: url.appendingPathComponent("logout"))
        logoutRequest.addValue(appVersion, forHTTPHeaderField: "app-version")
        logoutRequest.addValue("ios", forHTTPHeaderField: "platform")
        return URLSession.shared
            .dataTaskPublisher(for: logoutRequest)
            .map { $0.data }
            .decode(type: LogoutResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
         */

        return Just(LogoutResponse())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()

    }

}
