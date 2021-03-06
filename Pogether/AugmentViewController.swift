//
//  AugmentViewController.swift
//  Pogether
//
//  Created by KiraMelody on 2017/2/15.
//  Copyright © 2017年 KiraMelody. All rights reserved.
//

import UIKit

class AugmentViewController: ScrollImageViewController {

    var resultPhoto: UIImage!
    var groundView: UIView!
    var slider: UISlider!
    var sliderLabel : UILabel!
    
    var brightness: CGFloat! = 0
    var saturation: CGFloat! = 1
    var contrast: CGFloat! = 1
    
    func initialize()
    {
        let a0 = UIBarButtonItem(image: #imageLiteral(resourceName: "EditPhoto_Brightness"), style: .plain, target: self, action: #selector(brightnessSlider))
        let a1 = UIBarButtonItem(image: #imageLiteral(resourceName: "EditPhoto_Saturation"), style: .plain, target: self, action: #selector(saturationSlider))
        let a2 = UIBarButtonItem(image: #imageLiteral(resourceName: "EditPhoto_Contrast"), style: .plain, target: self, action: #selector(contrastSlider))
        let cancel = UIBarButtonItem(image: #imageLiteral(resourceName: "EditPhoto_Cancel"), style: .plain, target: self, action: #selector(backToLast))
        let save = UIBarButtonItem(image: #imageLiteral(resourceName: "EditPhoto_Save"), style: .plain, target: self, action: #selector(backToLast))
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let barArray = [cancel, space, a0, space, a1, space, a2, space, save]
        self.toolbarItems = barArray
        
        groundView = UIView()
        groundView.backgroundColor = ColorandFontTable.primaryPink
        
        slider = UISlider()
        slider.minimumTrackTintColor = ColorandFontTable.purple
        slider.maximumTrackTintColor = ColorandFontTable.fillGray
        slider.thumbTintColor = UIColor.white
        slider.value = 0.0
        slider.minimumValue = 0.0
        slider.maximumValue = 1.0
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        sliderLabel = UILabel()
        sliderLabel.font = UIFont.systemFont(ofSize: 14)
        sliderLabel.textColor = UIColor.white
        super.setScrollView()
        scrollImageView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(20)
            make.bottom.equalTo(self.view).offset(-50)
            make.left.equalTo(self.view).offset(10)
            make.right.equalTo(self.view).offset(-10)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        self.view.addSubview(groundView)
        self.view.addSubview(slider)
        self.view.addSubview(sliderLabel)
        groundView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view).offset(-45)
            make.height.equalTo(60)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        slider.snp.makeConstraints { (make) in
            make.centerX.equalTo(groundView)
            make.top.equalTo(groundView).offset(10)
            make.height.equalTo(20)
            make.width.equalTo(280)
        }
        sliderLabel.snp.makeConstraints { (make) in
            make.top.equalTo(slider.snp.bottom).offset(8)
            make.centerX.equalTo(slider)
        }
        self.view.backgroundColor = ColorandFontTable.groundGray
        self.groundView.isHidden = true
        self.slider.isHidden = true
        self.sliderLabel.isHidden = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        resultPhoto = ImageProcessing.colorControlsWithOriginalImage(image: photo, brightness: brightness, saturation: saturation, contrast: contrast)
        photoImageView.image = resultPhoto
        self.navigationController?.setToolbarHidden(false, animated: false)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated: false)
    }
    func brightnessSlider()
    {
        self.groundView.isHidden = false
        self.slider.isHidden = false
        self.sliderLabel.isHidden = false
        slider.value = 0.5
        sliderLabel.text = "亮度"
        
    }
    func saturationSlider()
    {
        self.groundView.isHidden = false
        self.slider.isHidden = false
        self.sliderLabel.isHidden = false
        sliderLabel.text = "饱和度"
        slider.value = 0.5
    }
    func contrastSlider()
    {
        self.groundView.isHidden = false
        self.slider.isHidden = false
        self.sliderLabel.isHidden = false
        sliderLabel.text = "对比度"
        slider.value = 0.0
    }
    func backToLast()
    {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    func sliderValueChanged()
    {
        if (sliderLabel.text?.contains("亮度"))!
        {
            brightness = CGFloat(slider.value) * 2 - 1 //range[-1,1]
        } else if (sliderLabel.text?.contains("饱和度"))! {
            saturation = CGFloat(slider.value) * 2 //range[0,2]
        } else if (sliderLabel.text?.contains("对比度"))! {
            contrast = CGFloat(slider.value) * 2 + 1 //range[1,3]
        }
        
        resultPhoto = ImageProcessing.colorControlsWithOriginalImage(image: photo, brightness: brightness, saturation: saturation, contrast: contrast)
        photoImageView.image = resultPhoto
    }
}
