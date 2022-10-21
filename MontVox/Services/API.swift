//
//  API.swift
//  MontVox
//
//  Created by João Victor Ipirajá de Alencar on 19/10/22.
//

import Foundation
import UIKit



// MARK: - ResponseType
enum ResponseType {
    
    init(_ response: HTTPURLResponse?){
        switch response?.statusCode ?? 0{
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


// MARK: - APICache

struct APICacheConfig {
    let countLimit: Int
    let memoryLimit: Int
    static let defaultConfig = APICacheConfig(countLimit: 100, memoryLimit: 1024 * 1024 * 100) // 100 MB
}

final class APICache <T: AnyObject>{
    
    private let config: APICacheConfig
    private let lock = NSLock()
    
    
    //Dados já decodificados
    private lazy var data: NSCache<NSNumber, T> = {
        let cache = NSCache<NSNumber, T>()
        cache.countLimit = config.countLimit
        return cache
    }()
    
    init(config: APICacheConfig = .defaultConfig){
        self.config = config
    }
    
    func insertData(_ data: T?, byId id: Int){
        guard let data = data else {return removeData(byId: id)}
        lock.lock(); defer{ lock.unlock()}
        self.data.setObject(data, forKey: id as NSNumber)
    }
    
    func removeData(byId id: Int){
        lock.lock(); defer{ lock.unlock()}
        self.data.removeObject(forKey: id as NSNumber)
    }
    
   func getData(byId id:Int) -> T?{
        return data.object(forKey: id as NSNumber)
    }
    
    subscript(_ id: Int) -> T?{
        get{
            return getData(byId: id)
        }
        
        set{
            return insertData(newValue, byId: id)
        }
    }
    
    
    
}


// MARK: - API

class API{
    
    
    static let ImageCache = APICache<UIImage>()
    
    
    struct APIResponse<T>{
        var result: T? = nil
        var response: ResponseType = .undefined
    }
    
    
    
    static func fetchImage(urlString: String, by id: Int , completion: @escaping (APIResponse<UIImage>) -> ()){
        
        
        if let imageonCache = ImageCache.getData(byId: id){
                        
            completion(.init(
                result: imageonCache,
                response: .success)
            )
            
        }else{
            let urlRequest = URLRequest(url: URL(string: urlString)!)
            
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
    
    static func fetchData<T: Decodable>(arrayOf type: T.Type, urlString: String, completion: @escaping (APIResponse<Array<T>>) -> ())  async{
        
        let urlRequest = URLRequest(url: URL(string: urlString)!)
        
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
