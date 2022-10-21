//
//  HomeViewModel.swift
//  MontVox
//
//  Created by João Victor Ipirajá de Alencar on 19/10/22.
//

import Foundation
import UIKit



// MARK: - Pictograms
struct Pictogram: Codable {

    let categories: [String]
    let tags: [String?]
    let id: Int
    let keywords: [Keyword]

    enum CodingKeys: String, CodingKey {
        case categories,tags, keywords
        case id = "_id"
    }
    
    
    internal init(categories: [String], tags: [String?], id: Int, keywords: [Keyword]) {
        self.categories = categories
        self.tags = tags
        self.id = id
        self.keywords = keywords
    }
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.categories = try container.decodeIfPresent([String].self, forKey: .categories) ?? []
        self.tags = try container.decodeIfPresent([String?].self, forKey: .tags) ?? []
        self.keywords = try container.decodeIfPresent([Keyword].self, forKey: .keywords) ?? []
        self.id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
    }
    
    static let mock = Pictogram(categories: [], tags: [], id: 1, keywords: [
        Keyword.mock
    ])
    
  
}

// MARK: - Keyword
struct Keyword: Codable {
    
    
    let meaning: String
    let keyword: String
    let plural: String
  
    
    internal init(meaning: String, keyword: String, plural: String) {
        self.meaning = meaning
        self.keyword = keyword
        self.plural = plural
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.meaning = try container.decodeIfPresent(String.self, forKey: .meaning) ?? ""
        self.keyword = try container.decodeIfPresent(String.self, forKey: .keyword) ?? ""
        self.plural = try container.decodeIfPresent(String.self, forKey: .plural) ?? ""
    }
    
    static var mock = Keyword(meaning: "-", keyword: "Academy", plural: "Academies")
    
}


