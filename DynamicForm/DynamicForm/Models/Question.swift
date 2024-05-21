//
//  Question.swift
//  DynamicForm
//
//  Created by Jess Melanson on 5/19/24.
//

import Foundation

struct Question: Codable {
  let uuid: String
  let prompt: String
  let answers: [String]
  let nextItemUuids: [String]
  let nextItemTypes: [String]
}
