//
//  AlbumTableViewController.swift
//  Pogether
//
//  Created by KiraMelody on 2017/1/17.
//  Copyright © 2017年 KiraMelody. All rights reserved.
//

import UIKit

class AlbumTableViewController: UITableViewController {
    
    var isSetting = true
    var albumArray = [Album]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set properties
        tableView.estimatedRowHeight = 70
        tableView.rowHeight = 70
        tableView.delegate = self
        tableView.backgroundColor = ColorandFontTable.groundGray
        tableView.dataSource = self
        tableView.sectionIndexColor = ColorandFontTable.primaryPink
        tableView.sectionIndexBackgroundColor = UIColor.clear
        tableView.tableFooterView = UIView(frame: .zero)
        
        //set navigation bar
        self.title = "素材库"
        initialize()
        registerForCell()
        self.navigationController?.navigationBar.isHidden = false
        
        albumArray = [Album(name: "默认相册", count: 50, limit: Limit.all), Album(name: "背景图片", count: 50, limit: Limit.myself), Album(name: "Pogether 数据库", count: 50, limit: Limit.somecan), Album(name: "个人收藏", count: 50, limit: Limit.somenot)]
        
    }
    
    //show navigation bar
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated: false)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func initialize(){
        //set navigation item
        var backImage = #imageLiteral(resourceName: "ContactList_Back")
        backImage = backImage.withRenderingMode(.alwaysOriginal)
        let backItem = UIBarButtonItem (image: backImage, style: .plain, target: self, action: #selector(backToLast))
        self.navigationItem.leftBarButtonItem = backItem
        if isSetting {
            var addImage = #imageLiteral(resourceName: "Album_Add")
            addImage = addImage.withRenderingMode(.alwaysOriginal)
            let addAlbum = UIBarButtonItem (image: addImage, style: .plain, target: self, action: #selector(addNewAlbum))
            self.navigationItem.rightBarButtonItem = addAlbum
        }
    }
    
    func registerForCell() {
        tableView.register(AlbumTableViewCell.self, forCellReuseIdentifier: "AlbumTableViewCell")
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return albumArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //set cell texts
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumTableViewCell", for: indexPath) as! AlbumTableViewCell
        cell.album = albumArray[indexPath.row]
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! AlbumTableViewCell
        let avc = PhotoCollectionViewController()
        avc.isSetting = self.isSetting
        avc.limit = albumArray[indexPath.row].limit
        avc._delegate = cell
        self.navigationController?.pushViewController(avc, animated: false)
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return isSetting
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete)
        {
            albumArray.remove(at: indexPath.row)
            print(albumArray)
            tableView.reloadData()
        }
    }
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    
    func backToLast() {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    func addNewAlbum() {
        let alertController = UIAlertController(title: "新建相册", message: "请为此相册输入名称", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
        let okAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.default, handler: {
            action in
            let name = alertController.textFields?[0].text
            
            let url = URL(string: "https://\(APIurl)/album/create")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            request.httpBody = "{\n  \"albumname\": \(name!)\n}".data(using: .utf8)
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let response = response, let data = data {
                    let json = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: Any]
                    let id = json["id"]! //string
                    let getName = json["name"]! //string
                    let count = json["count"]! //int
                    let avatar = json["avatar"]! //string
                    let limit = json["limit"]! //enum
                    
                    self.albumArray.append(Album(name: name!, count: 0, limit: Limit.all))
                    self.tableView.reloadData()
                } else {
                    print(error!)
                }
            }
            
            task.resume()
            
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = "默认相册"
        }
        self.present(alertController, animated: true, completion: nil)
    }
}


