//
//  API.swift
//  MontVox
//
//  Created by João Victor Ipirajá de Alencar on 19/10/22.
//

import Foundation
import UIKit


// MARK: - DownloadDelegate



extension API{
    struct Response<T> {   
        enum TypeOf {
            init(_ response: HTTPURLResponse?) {
                guard let response = response else {
                    self = .undefined
                    return
                }
                switch response.statusCode {
                case 100..<200:
                    self = .informational
                case 200..<300:
                    self = .success
                case 300..<400:
                    self = .redirection
                case 400..<500:
                    self = .clientError
                case 500..<600:
                    self = .serverError
                default:
                    self = .undefined
                }
            }
            case informational
            case success
            case redirection
            case clientError
            case serverError
            case undefined
        }
        
        var result: T?
        var response: Response.TypeOf = .undefined
    }
}

// MARK: - Route




extension API{
    internal enum Locale: String {
        case ptBR = "br"
    }
    struct Domain {
        
        static let domain = "https://api.arasaac.org/api"
        
        enum Route {
            case pictograms(all: Locale)
            case pictogram(id: Int)
            
            var toURL: URL? {
                get {
                    switch self {
                        case .pictograms(all: let locale):
                            return URL(string: "\(domain)/pictograms/all/\(locale.rawValue)")
                        case .pictogram(id: let id):
                            return URL(string: "\(domain)/pictograms/\(id)")
                    }
                }
            }
        }
    }
}

extension API {
    internal struct Identifier: Codable{
        var id:Int
        
        init(id: Int?){
            self.id = id ?? -1
        }
        init(data: Data) throws {
            self = try JSONDecoder().decode(Identifier.self, from: data)
        }

        init(_ json: String, using encoding: String.Encoding = .utf8) throws {
            guard let data = json.data(using: encoding) else {
                throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
            }
            try self.init(data: data)
        }

        init(fromURL url: URL) throws {
            try self.init(data: try Data(contentsOf: url))
        }

        func jsonData() throws -> Data {
            return try JSONEncoder().encode(self)
        }

        func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
            return String(data: try self.jsonData(), encoding: encoding)
        }
    }
    
    
}

// MARK: - Cache

extension API{
    
    final class Cache <T: AnyObject> {
        
        struct Config {
            let countLimit: Int
            let memoryLimit: Int
            
            init(countLimit: Int = 100, memoryLimit: Int = 1024 * 1024 * 100) {
                self.countLimit = countLimit
                self.memoryLimit = memoryLimit
            }
        }
        
        private let config: API.Cache<T>.Config
        private let lock = NSLock()
        // Dados já decodificados
        private lazy var data: NSCache<NSNumber, T> = {
            let cache = NSCache<NSNumber, T>()
            cache.countLimit = config.countLimit
            return cache
        }()
        init(config: API.Cache<T>.Config = .init()) {
            self.config = config
        }
        func insertData(_ data: T?, byId id: Int) {
            guard let data = data else {return removeData(byId: id)}
            lock.lock(); defer { lock.unlock() }
            self.data.setObject(data, forKey: id as NSNumber)
        }
        func removeData(byId id: Int) {
            lock.lock(); defer { lock.unlock() }
            self.data.removeObject(forKey: id as NSNumber)
        }
       func getData(byId id:Int) -> T? {
            return data.object(forKey: id as NSNumber)
        }
        subscript(_ id: Int) -> T? {
            get {
                return getData(byId: id)
            }
            set {
                return insertData(newValue, byId: id)
            }
        }
    }

}

class API{
    static let ImageCache = API.Cache<UIImage>()
    
    static func fetchImage( route: API.Domain.Route, by id: Int , completion: @escaping (API.Response<UIImage>) -> ()){
        if let imageonCache = ImageCache.getData(byId: id){
                        
            completion(.init(
                result: imageonCache,
                response: .success)
            )
        } else {
            let urlRequest = URLRequest(url: route.toURL!)
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                      let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                      let data = data, error == nil,
                      let image = UIImage(data: data)
                else {
                    completion(.init(
                        result: nil,
                        response: .init(response as? HTTPURLResponse)
                    ))
                    
                    return
                }
                
                //Salva imagens em cache
                ImageCache.insertData(image, byId: id)
                
                completion(.init(
                    result: image,
                    response: .success)
                )
                
            }.resume()
        }
        
        
    }
    
    static func fetchData<T: Decodable>(arrayOf type: T.Type, route: API.Domain.Route, completion: @escaping (API.Response<Array<T>>) -> ())  async{
        
        let urlRequest = URLRequest(url: route.toURL!)
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            
            if let data = data {
                
                do{
                    let dataDecoded = try JSONDecoder().decode(Array<T>.self, from: data)
                    
                    completion(.init(
                        result: dataDecoded,
                        response: .success
                    ))
                    
                }catch {
                    print(error)
                }
                
                
                
            }else{
                completion(.init(
                    result: nil,
                    response: .init(response as? HTTPURLResponse))
                )
                
            }
            
        }.resume()
    }
    
}
