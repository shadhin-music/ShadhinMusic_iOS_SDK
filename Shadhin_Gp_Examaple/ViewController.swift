//
//  ViewController.swift
//  Shadhin_Gp_Examaple
//
//  Created by Maruf on 2/6/24.
//

import UIKit
import Shadhin_Gp

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
     
    @IBAction func gotoHome(_ sender: Any) {
      //  ShadhinGP.shared.gotoHome(with: self)
    }
}

class FirstViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            view.overrideUserInterfaceStyle = .light
        }
        view.backgroundColor = .white
        //self.title = "Back"
       // setupButton()
    }
    
    private func setupButton() {
        let button = UIButton(type: .system)
        button.setTitle("Go To Shadhin Music App", for: .normal)
        button.backgroundColor = UIColor(named: "tabBarColor")
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 12.0
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(button)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 250),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func buttonTapped() {
       // ShadhinGP.shared.gotoShadhinMusic(parentVC: self, accesToken: "")
    }
}


class FourthViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.title = "Fourth"
    }
}


