//
//  Result.swift
//  DynamicForm
//
//  Created by Jess Melanson on 5/19/24.
//

import Foundation

struct Result: Codable {
  let uuid: String
  let extendedConstructionNumbers: String
  let lookUpConstructionNumber: String
  let notes: String?
}
