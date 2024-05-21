//
//  QuestionPresenter.swift
//  DynamicForm
//
//  Created by Jess Melanson on 5/19/24.
//

import Foundation

class QuestionPresenter {
  private unowned var view: QuestionViewType
  private let apiManager = APIManager()
  
  private var breadcrumbs: String = ""
  
  init(view: QuestionViewType) {
    self.view = view
  }
  
  func viewDidLoad() {
    updateView(nextItemUuid: nil)
  }
  
  func handleButtonTap(
    selectedAnswer: String?,
    nextItemUuid: String?,
    nextItemType: QuestionButton.ItemType?
  ) {
    updateView(
      selectedAnswer: selectedAnswer,
      nextItemUuid: nextItemUuid,
      nextItemType: nextItemType
    )
  }
  
  func reset() {
    breadcrumbs = ""
    updateView(nextItemUuid: nil)
  }
  
  /// Pass `nil` for   `questionUuid` to get first question.
  private func updateView(
    selectedAnswer: String? = nil,
    nextItemUuid: String?,
    nextItemType: QuestionButton.ItemType? = nil
  ) {
    view.loadingSubject.send(true)
    
    let questionCompletion: (Question?) -> Void = { [weak self] question in
      self?.updateBreadcrumbs(selectedAnswer: selectedAnswer, newQuestion: question)
      DispatchQueue.main.async {
        self?.view.configureView(breadcrumbs: self?.breadcrumbs, question: question)
      }
      self?.view.loadingSubject.send(false)
    }
    
    if let nextItemUuid, nextItemType == .question {
      apiManager.getQuestion(uuid: nextItemUuid) { question in
        questionCompletion(question)
      }
    } else if let nextItemUuid, nextItemType == .result {
      apiManager.getResult(uuid: nextItemUuid) { [weak self] result in
        self?.updateBreadcrumbs(selectedAnswer: selectedAnswer, newQuestion: nil)
        DispatchQueue.main.async {
          self?.view.configureView(breadcrumbs: self?.breadcrumbs, result: result)
        }
        self?.view.loadingSubject.send(false)
      }
    } else {
      apiManager.getFirstQuestion { question in
        questionCompletion(question)
      }
    }
  }
  
  private func updateBreadcrumbs(
    selectedAnswer: String?,
    newQuestion: Question?
  ) {
    if let newQuestion,
       breadcrumbs.isEmpty {
      breadcrumbs += "\(newQuestion.prompt)"
    } else if let selectedAnswer,
              let newQuestion {
      breadcrumbs += ": \(selectedAnswer) > \(newQuestion.prompt)"
    } else if let selectedAnswer {
      breadcrumbs += ": \(selectedAnswer)"
    }
  }
}
