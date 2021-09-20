import Combine
import Foundation

struct LoginResponse: Codable {
    let token: AuthToken
}

typealias AuthToken = String

protocol UnauthenticatedNetworkClient {
    func login(username: String, password: String) -> AnyPublisher<LoginResponse, Error>
}

final class UnauthenticatedNetworkClientImpl: UnauthenticatedNetworkClient {

    private let url: URL
    private let appVersion: String

    init(url: URL, appVersion: String) {
        self.url = url
        self.appVersion = appVersion
    }

    func login(username: String, password: String) -> AnyPublisher<LoginResponse, Error> {
        /*
            var loginRequest = URLRequest(url: url.appendingPathComponent("login"))
            loginRequest.addValue(appVersion, forHTTPHeaderField: "app-version")
            loginRequest.addValue("ios", forHTTPHeaderField: "platform")
            return URLSession.shared
                .dataTaskPublisher(for: loginRequest)
                .map { $0.data }
                .decode(type: LoginResponse.self, decoder: JSONDecoder())
                .eraseToAnyPublisher()
         */

        return Just(LoginResponse(token: "A_TOKEN"))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()

    }
}
