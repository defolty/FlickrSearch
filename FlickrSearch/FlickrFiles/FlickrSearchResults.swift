//
//  FlickrSearchResults.swift
//  FlickrSearch
//
//  Created by Nikita Nesporov on 03.08.2022.
//

import Foundation

///# FlickrSearchResults:
///# Структура, которая содержит поисковый запрос и результаты, найденные для этого поиска.
struct FlickrSearchResults {
    let searchTerm: String
    let searchResults: [FlickrPhoto]
}
