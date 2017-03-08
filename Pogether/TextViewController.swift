//
//  TextViewController.swift
//  Pogether
//
//  Created by KiraMelody on 2017/2/15.
//  Copyright © 2017年 KiraMelody. All rights reserved.
//

import WYCDynamicTextController

class TextViewController: WYCDynamicTextController
{
    
    var photoImageView: UIImageView!
    var photo: UIImage!
    var scrollImageView: UIScrollView!
    weak var _delegate: EditPhoto?
    func initialize()
    {
        photoImageView = UIImageView(frame: self.view.frame)
        photoImageView.contentMode = .scaleAspectFit
        photoImageView.image = photo
        
        let text = UIBarButtonItem(title: "添加文字", style: .plain, target: self, action: #selector(addText))
        let cancel = UIBarButtonItem(image: #imageLiteral(resourceName: "EditPhoto_Cancel"), style: .plain, target: self, action: #selector(backToLast))
        let save = UIBarButtonItem(image: #imageLiteral(resourceName: "EditPhoto_Save"), style: .plain, target: self, action: #selector(saveToLast))
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let barArray = [cancel, space, text, space, save]
        self.toolbarItems = barArray
        
        //创建并添加scrollView
        scrollImageView = UIScrollView()
        self.view.addSubview(scrollImageView)
        scrollImageView.backgroundColor = ColorandFontTable.groundGray
        scrollImageView.contentSize = photo.size
        scrollImageView.delegate = self
        scrollImageView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(20)
            make.bottom.equalTo(self.view).offset(-50)
            make.left.equalTo(self.view).offset(10)
            make.right.equalTo(self.view).offset(-10)
        }
        
        let scrollViewFrame = scrollImageView.frame
        let scaleWidth = scrollViewFrame.size.width / scrollImageView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollImageView.contentSize.height
        let minScale = min(scaleWidth, scaleHeight)
        scrollImageView.minimumZoomScale = 0.3
        scrollImageView.maximumZoomScale = 2.0
        scrollImageView.zoomScale = minScale
        scrollImageView.bouncesZoom = true
        scrollImageView.showsVerticalScrollIndicator = false
        scrollImageView.showsHorizontalScrollIndicator = false
        photoImageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.view.frame.width - 20, height: self.view.frame.height - 190)))
        photoImageView.image = photo
        photoImageView.contentMode = .scaleAspectFit
        scrollImageView.addSubview(photoImageView)
        
        centerScrollViewContents()
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(scrollViewDoubleTapped(recognizer:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        scrollImageView.addGestureRecognizer(doubleTapRecognizer)
        
        textField.isHidden = true
        textField.placeholder = "点击输入文字"
        textField.backgroundColor = ColorandFontTable.transparent
        textField.layer.borderColor = ColorandFontTable.primaryPink.cgColor
        view.bringSubview(toFront: textField)
        
        minDist = 20
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        initialize()
        self.view.backgroundColor = ColorandFontTable.groundGray
    }
    override func viewWillAppear(_ animated: Bool)
    {
        self.navigationController?.setToolbarHidden(false, animated: false)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    override func viewWillDisappear(_ animated: Bool)
    {
        self.navigationController?.setToolbarHidden(true, animated: false)
    }
    
    func backToLast()
    {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    func centerScrollViewContents()
    {
        let boundsSize = scrollImageView.bounds.size
        var contentsFrame = photoImageView.frame
        
        if contentsFrame.size.width < boundsSize.width
        {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        }
        else
        {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height
        {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        }
        else
        {
            contentsFrame.origin.y = 0.0
        }
        
        photoImageView.frame = contentsFrame
    }
    
    func addText()
    {
        textField.isHidden = !textField.isHidden
        textField.layer.borderWidth = 1
        if textField.isHidden
        {
            toolbarItems![2].title = "添加文字"
        }
        else
        {
            toolbarItems![2].title = "删除文字"
        }
    }
    
    @objc func tap(_ sender: UITapGestureRecognizer)
    {
        let loc = sender.location(in: self.view)
        if textField.frame.contains(loc)
        {
            textField.layer.borderWidth = 1
        } else
        {
            textField.layer.borderWidth = 0
            textField.endFloatingCursor()
        }
        if textField.text == "" && !textField.isHidden
        {
            addText()
        }
    }
    
    func saveToLast()
    {
        self.view.backgroundColor = UIColor.clear
        self.textField.layer.borderWidth = 0
        UIGraphicsBeginImageContext(self.photoImageView.bounds.size)
        self.view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let viewImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self._delegate?.editPhoto(photo: viewImage)
        //UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil)
        backToLast()
    }
    
    override func stateChanged()
    {
        if gestureState != .NONE
        {
            textField.layer.borderWidth = 1
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        textField.layer.borderWidth = 1
    }
}

extension TextViewController: UIScrollViewDelegate
{
    // MARK: - UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView?
    {
        return photoImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView)
    {
        centerScrollViewContents()
    }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat)
    {
        if scrollView.minimumZoomScale >= scale
        {
            scrollView.setZoomScale(0.3, animated: true)
        }
        if scrollView.maximumZoomScale <= scale
        {
            scrollView.setZoomScale(2.0, animated: true)
        }
    }
    
    func scrollViewDoubleTapped(recognizer: UITapGestureRecognizer)
    {
        let pointInView = recognizer.location(in: photoImageView)
        
        var newZoomScale = scrollImageView.zoomScale * 1.5
        newZoomScale = min(newZoomScale, scrollImageView.maximumZoomScale)
        
        let scrollViewSize = scrollImageView.bounds.size
        let w = scrollViewSize.width / newZoomScale
        let h = scrollViewSize.height / newZoomScale
        let x = pointInView.x - (w / 2.0)
        let y = pointInView.y - (h / 2.0)
        
        let rectToZoomTo = CGRect(x: x, y: y, width: w, height: h)
        
        scrollImageView.zoom(to: rectToZoomTo, animated: true)
    }
    
}

