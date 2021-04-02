//
//  AnimationViewController.swift
//  FaceRecognizer
//
//  Created by Сергей Горейко on 31.03.2021.
//

import UIKit

class AnimationViewController: UIViewController {

    private let imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 107, y: 250, width: 200, height: 200))
        imageView.image = UIImage(named: "logo")
        
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel(frame: CGRect(x: 69.67, y: 522.0, width: 275.0, height: 42.0))
        label.text = "Face Recognizer"
        label.textColor = .systemYellow
        label.font = .boldSystemFont(ofSize: 35)
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
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
                    let homeVC = HomeViewController()
                    homeVC.modalTransitionStyle = .crossDissolve
                    homeVC.modalPresentationStyle = .fullScreen
                    self.present(homeVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func setupView() {
        view.backgroundColor = #colorLiteral(red: 1, green: 0.2509803922, blue: 1, alpha: 1)
        
        view.addSubview(imageView)
        view.addSubview(label)
    }
}
