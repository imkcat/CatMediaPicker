//
//  ViewController.swift
//  Example-iOS
//
//  Created by Kcat on 2018/3/21.
//  Copyright © 2018年 ImKcat. All rights reserved.
//

import UIKit
import CatMediaPicker

class ViewController: UIViewController, CatPhotosPickerControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let mediaPicker = CatPhotosPickerController(configure: CatPhotosPickerControllerConfigure())
        mediaPicker.pickerControllerDelegate = self
        self.present(mediaPicker, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    // MARK: - CatPhotosPickerControllerDelegate
    func didCancelPicking(pickerController: CatPhotosPickerController) {
        pickerController.dismiss(animated: true, completion: nil)
    }
    
    func didFinishPicking(pickerController: CatPhotosPickerController, media: [CatMedia]) {
        pickerController.dismiss(animated: true, completion: nil)
        print(media)
    }
    
}
