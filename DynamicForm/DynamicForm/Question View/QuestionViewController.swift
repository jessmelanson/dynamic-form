//
//  QuestionViewController.swift
//  DynamicForm
//
//  Created by Jess Melanson on 5/19/24.
//

import UIKit
import Combine

private let padding: CGFloat = 20
private let errorString = "Something went wrong. Try again later."

protocol QuestionViewType: AnyObject {
  var loadingSubject: CurrentValueSubject<Bool, Never> { get set }
  func configureView(breadcrumbs: String?, question: Question?)
  func configureView(breadcrumbs: String?, result: Result?)
}

class QuestionViewController: UIViewController, QuestionViewType {
  
  private let scrollView: UIView = {
    let v = UIScrollView()
    v.backgroundColor = .white
    v.contentInsetAdjustmentBehavior = .never
    return v
  }()
  private let breadcrumbLabel: UILabel = {
    let v = UILabel()
    v.font = .preferredFont(forTextStyle: .footnote)
    v.textColor = .lightGray
    v.numberOfLines = 0
    v.lineBreakMode = .byWordWrapping
    return v
  }()
  private let titleLabel: UILabel = {
    let v = UILabel()
    v.font = .preferredFont(forTextStyle: .title1)
    v.textColor = .black
    v.numberOfLines = 0
    v.lineBreakMode = .byWordWrapping
    return v
  }()
  private let stackView: UIStackView = {
    let v = UIStackView()
    v.axis = .vertical
    v.distribution = .fill
    v.alignment = .fill
    v.spacing = padding
    return v
  }()
  private let loadingIndicator: UIActivityIndicatorView = {
    let v = UIActivityIndicatorView(style: .large)
    v.hidesWhenStopped = true
    return v
  }()
  
  private lazy var presenter = QuestionPresenter(view: self)
  var loadingSubject = CurrentValueSubject<Bool, Never>(false)
  private var cancellables = Set<AnyCancellable>()

  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    presenter.viewDidLoad()
  }
  
  deinit {
    cancellables = []
  }
  
  func configureView(
    breadcrumbs: String?,
    question: Question?
  ) {
    updateBreadcrumbs(breadcrumbs)
    
    titleLabel.text = question?.prompt ?? errorString
    
    stackView.subviews.forEach {
      $0.removeFromSuperview()
    }
    
    guard let question else { return }
    question.answers.enumerated().forEach { index, answer in
      let button = QuestionButton(
        nextItemUuid: question.nextItemUuids[index],
        nextItemType: .init(rawValue: question.nextItemTypes[index]),
        title: answer
      )
      button.addTarget(self, action: #selector(self.buttonTapped), for: .touchUpInside)
      stackView.addArrangedSubview(button)
    }
    view.layoutIfNeeded()
  }
  
  func configureView(breadcrumbs: String?, result: Result?) {
    updateBreadcrumbs(breadcrumbs)
    
    titleLabel.text = "Your Result"
    
    stackView.subviews.forEach {
      $0.removeFromSuperview()
    }
    
    guard let result else {
      titleLabel.text = errorString
      return
    }
    
    let resultData: [(String, String?)] = [
      ("Extended Construction Number", result.extendedConstructionNumbers),
      ("Look-Up Construction Number", result.lookUpConstructionNumber),
      ("Notes", result.notes)
    ]
    resultData.forEach { tuple in
      guard let selection = tuple.1, !selection.isEmpty else { return }
      let label = createLabel(type: tuple.0, selection: selection)
      label.translatesAutoresizingMaskIntoConstraints = false
      stackView.addArrangedSubview(label)
    }
    
    var config = UIButton.Configuration.filled()
    config.cornerStyle = .medium
    config.title = "Start Over"
    config.titleAlignment = .center
    let button = UIButton(configuration: config)
    button.addTarget(self, action: #selector(startOverButtonTapped), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    stackView.addArrangedSubview(button)
  }
  
  @objc private func buttonTapped(_ sender: QuestionButton) {
    presenter.handleButtonTap(
      selectedAnswer: sender.titleLabel?.text,
      nextItemUuid: sender.nextItemUuid, 
      nextItemType: sender.nextItemType
    )
  }
  
  @objc private func startOverButtonTapped() {
    presenter.reset()
  }
  
  private func createLabel(type: String, selection: String) -> UILabel {
    let label = UILabel()
    label.font = .preferredFont(forTextStyle: .callout)
    label.textColor = .black
    label.lineBreakMode = .byWordWrapping
    label.numberOfLines = 0
    label.text = "\(type.uppercased()): \(selection)"
    return label
  }
  
  private func updateBreadcrumbs(_ breadcrumbs: String?) {
    self.breadcrumbLabel.alpha = (breadcrumbs == nil || breadcrumbs == "") ? 0 : 1
    self.breadcrumbLabel.text = breadcrumbs
  }

  private func setupView() {
    view.backgroundColor = .white
    
    [scrollView, loadingIndicator].forEach {
      $0.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview($0)
    }
    
    [breadcrumbLabel, titleLabel, stackView].forEach {
      $0.translatesAutoresizingMaskIntoConstraints = false
      scrollView.addSubview($0)
    }
    
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
      scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding),
      
      loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      
      breadcrumbLabel.topAnchor.constraint(equalTo: scrollView.topAnchor),
      breadcrumbLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
      breadcrumbLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
      
      titleLabel.topAnchor.constraint(equalTo: breadcrumbLabel.bottomAnchor, constant: padding),
      titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
      titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
      
      stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: padding),
      stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
      stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
      stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -padding)
    ])
    
    loadingSubject.sink { [weak self] isLoading in
      DispatchQueue.main.async {
        isLoading ? self?.loadingIndicator.startAnimating() : self?.loadingIndicator.stopAnimating()
      }
    }.store(in: &cancellables)
  }
}

