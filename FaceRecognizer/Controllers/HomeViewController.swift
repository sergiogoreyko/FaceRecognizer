//
//  HomeViewController.swift
//  FaceRecognizer
//
//  Created by Сергей Горейко on 31.03.2021.
//

import UIKit

class HomeViewController: UIViewController {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "logo")
        
        return imageView
    }()
    
    private let faceRecognitionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonToFaceRecognition(_:)), for: .touchUpInside)
        button.setTitle("Start recognition", for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 20)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .systemOrange
        button.layer.cornerRadius = 10
        button.layer.borderColor = UIColor.systemOrange.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowColor = UIColor.systemOrange.cgColor
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    @objc  private func buttonToFaceRecognition(_ sender: UIButton) {
        let recognitionVC = RecognitionViewController()
        navigationController?.pushViewController(recognitionVC, animated: true)
    }
    
    private func setupView() {
        title = "Home Page"
        navigationController?.navigationBar.tintColor = .black
        
        view.backgroundColor = #colorLiteral(red: 0.3450980392, green: 0.3607843137, blue: 0.5882352941, alpha: 1)
        
        view.addSubview(imageView)
        view.addSubview(faceRecognitionButton)
        
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        faceRecognitionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        faceRecognitionButton.widthAnchor.constraint(equalToConstant: view.frame.width - 100).isActive = true
        faceRecognitionButton.heightAnchor.constraint(equalToConstant: 70).isActive = true
        faceRecognitionButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        
    }
}
