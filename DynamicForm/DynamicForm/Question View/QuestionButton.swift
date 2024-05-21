//
//  QuestionButton.swift
//  DynamicForm
//
//  Created by Jess Melanson on 5/20/24.
//

import UIKit

class QuestionButton: UIButton {
  enum ItemType: String {
    case question = "question"
    case result = "result"
  }
  
  let nextItemUuid: String?
  let nextItemType: ItemType?
  
  init(
    nextItemUuid: String,
    nextItemType: ItemType?,
    title: String
  ) {
    self.nextItemUuid = nextItemUuid
    self.nextItemType = nextItemType
    
    var config = UIButton.Configuration.filled()
    config.title = title
    config.cornerStyle = .medium
    config.titleAlignment = .leading
    
    super.init(frame: .zero)
    super.configuration = config
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
