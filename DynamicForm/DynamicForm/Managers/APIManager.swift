//
//  APIManager.swift
//  DynamicForm
//
//  Created by Jess Melanson on 5/19/24.
//

import Foundation
import Combine

private let networkError = "Network Error"

enum APIRoute {
  case getCeilingType
  case getQuestion(String)
  case getResult(String)
  
  var url: URL? {
    let endpoint: String
    switch self {
    case .getCeilingType:
      endpoint = "/question/ceiling-type"
    case .getQuestion(let uuid):
      endpoint = "/question/\(uuid)"
    case .getResult(let uuid):
      endpoint = "/result/\(uuid)"
    }
    
    return URL(string: "http://localhost:8000\(endpoint)")
  }
}

class APIManager {
  
  static let shared = APIManager()
  
  func getFirstQuestion(completion: @escaping (Question?) -> Void) {
    request(route: .getCeilingType) { [weak self] responseData in
      guard let self else { return }
      questionCompletion(responseData, completion: completion)
    }
  }
  
  func getQuestion(uuid: String, completion: @escaping (Question?) -> Void) {
    request(route: .getQuestion(uuid)) { [weak self] responseData in
      guard let self else { return }
      questionCompletion(responseData, completion: completion)
    }
  }
  
  func getResult(uuid: String, completion: @escaping (Result?) -> Void) {
    request(route: .getResult(uuid)) { [weak self] responseData in
      guard let self,
            let responseData else {
        print(networkError)
        completion(nil)
        return
      }
      
      let decodedResponse = decodeJSON(json: responseData, as: Result.self)
      completion(decodedResponse)
    }
  }
  
  private func questionCompletion(_ responseData: Data?, completion: (Question?) -> Void) {
    guard let responseData else {
      print(networkError)
      completion(nil)
      return
    }
    
    let decodedResponse = decodeJSON(json: responseData, as: Question.self)
    completion(decodedResponse)
  }
  
  private func request(route: APIRoute, completion: @escaping (_ responseData: Data?) -> Void) {
    guard let url = route.url else { return }
    let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { (data, response, error) in
      guard let httpResponse = response as? HTTPURLResponse, let data = data else {
        print(error)
        completion(nil)
        return
      }
      
      if error != nil || httpResponse.statusCode != 200 {
        print("\(error?.localizedDescription ?? networkError)")
        completion(nil)
        return
      }
      
      completion(data)
    }
    
    task.resume()
  }
  
  private func decodeJSON<T: Decodable>(json: Data, as decodedType: T.Type) -> T? {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    
    if let decodedData = try? decoder.decode(decodedType.self, from: json) {
      return decodedData
    }
    
    return nil
  }
}
