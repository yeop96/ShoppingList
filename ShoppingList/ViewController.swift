//
//  ViewController.swift
//  ShoppingList
//
//  Created by yeop on 2021/11/04.
//

import UIKit
import RealmSwift
import Toast

class ViewController: UIViewController {
    let localRealm = try! Realm()
    var tasks: Results<ShoppingList>!

    @IBOutlet weak var tableView: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        title = "쇼핑"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .plain, target: self, action: #selector(sortAlert))
        
        tasks = localRealm.objects(ShoppingList.self).sorted(byKeyPath: "regDate", ascending: false)
     
    }
    
    @objc func sortAlert(){
        //alert로 나중에 구현하기
        tasks = localRealm.objects(ShoppingList.self).sorted(byKeyPath: "shoppingContent", ascending: false)
        tableView.reloadData()
    }
    
   
    
    @IBAction func addButtonClicked(_ sender: UIButton) {
        
        tableView.reloadData()
    }
    
    
    
    @IBAction func checkButtonClicked(_ sender: UIButton) {
        //레코드에 대한 값 수정
        let taskUpdate = tasks[sender.tag]
        try! localRealm.write{
            taskUpdate.confirmed = !taskUpdate.confirmed
            tableView.reloadData()
        }
    
    }
    
    
    @IBAction func favoriteButtonClicked(_ sender: UIButton) {
        //레코드에 대한 값 수정
        let taskUpdate = tasks[sender.tag]
        try! localRealm.write{
            taskUpdate.favorite = !taskUpdate.favorite
            tableView.reloadData()
        }
    }
    
    

}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return section == 0 ? 1 : tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //구매 추가 섹션 셀
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingAddCell") as? ShoppingAddCell else{
                return UITableViewCell()
            }
            
            cell.selectionStyle = .none
            return cell
        }
        //구매 리스트 섹션 셀
        else{
            let row = tasks[indexPath.row]
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingListCell") as? ShoppingListCell else{
                return UITableViewCell()
            }
            
            cell.purchaseLabel.text = row.shoppingContent

            if row.confirmed{
                cell.confirmedCheckButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
            }
            else{
                cell.confirmedCheckButton.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
            }
            if row.favorite{
                cell.favoritStarButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            }
            else{
                cell.favoritStarButton.setImage(UIImage(systemName: "star"), for: .normal)
            }
            
            cell.confirmedCheckButton.tag = indexPath.row
            cell.favoritStarButton.tag = indexPath.row
            cell.selectionStyle = .none
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return indexPath.section == 0 ? 66 : 44
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete{
//            tableView.reloadData()
//        }
        let row = tasks[indexPath.row]
        try! localRealm.write{
            localRealm.delete(row)
            tableView.reloadData()
        }
    }
}

class ShoppingAddCell: UITableViewCell{
    let localRealm = try! Realm()
    
    @IBOutlet weak var purchaseAddButton: UIButton!
    
    @IBOutlet weak var purchaseTextField: UITextField!
    
    @IBAction func addButtonClicked(_ sender: UIButton) {
        
        if purchaseTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
            let windows = UIApplication.shared.windows
                        windows.last?.makeToast("구매할 목록을 입력하세요!", duration: 3.0, position: .top)
            return
        }

        // Add some tasks
        let task = ShoppingList(shoppingContent: purchaseTextField.text!, confirmed: false, favorite: false, regDate: Date())

        try! localRealm.write {
            localRealm.add(task)
        }
        
    }
}

class ShoppingListCell: UITableViewCell{
    
    @IBOutlet weak var purchaseLabel: UILabel!
    @IBOutlet weak var confirmedCheckButton: UIButton!
    @IBOutlet weak var favoritStarButton: UIButton!
    
    
}

