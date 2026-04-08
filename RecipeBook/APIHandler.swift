//
//  APIHandler.swift
//  RecipeBook
//
//  Created by Matheus Santos on 27/03/2026.
//

import Foundation

class APIHandler{
    
    //API BAse endpoit
    static var shared = APIHandler(baseURL: "https://www.themealdb.com/api/json/v1/1")
    
    var baseURL:URL
    
    init(baseURL: String) {
        //logica para validar URL
        self.baseURL = URL(string: baseURL)!
    }
    
}
