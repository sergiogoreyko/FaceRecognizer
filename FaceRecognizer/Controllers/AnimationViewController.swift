//
//  AnimationViewController.swift
//  FaceRecognizer
//
//  Created by Сергей Горейко on 31.03.2021.
//

import UIKit

class AnimationViewController: UIViewController {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        imageView.image = UIImage(named: "logo")
        
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 274, height: 42))
        label.text = "Face Recognizer"
        label.textColor = .systemYellow
        label.font = .boldSystemFont(ofSize: 35)
        label.textAlignment = .center
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        imageView.center = view.center
        label.frame.origin.x = (view.frame.width - label.frame.width) / 2
        label.frame.origin.y = view.frame.maxY - 92
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.animate()
        }
    }
    
    private func animate() {
        UIView.animate(withDuration: 1) {
            let size = self.view.frame.size.width * 1.05
            let diffX = size - self.view.frame.size.width
            let diffY = self.view.frame.size.height - size
            
            self.imageView.frame = CGRect(x: -(diffX/2),
                                          y: diffY/2,
                                          width: size,
                                          height: size)
            self.label.isHidden = true
        }
        
        UIView.animate(withDuration: 1.5) {
            self.imageView.alpha = 0
        } completion: { done in
            if done {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    let navVC = UINavigationController(rootViewController: HomeViewController())
                    navVC.modalPresentationStyle = .fullScreen
                    navVC.navigationBar.barTintColor = .systemOrange
                    self.present(navVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func setupView() {
        view.backgroundColor = #colorLiteral(red: 0.3450980392, green: 0.3607843137, blue: 0.5882352941, alpha: 1)
        
        view.addSubview(imageView)
        view.addSubview(label)
        
    }
}
