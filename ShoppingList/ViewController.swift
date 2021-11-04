//
//  ViewController.swift
//  ShoppingList
//
//  Created by yeop on 2021/11/04.
//

import UIKit
import RealmSwift
import Toast
import Zip
import MobileCoreServices


class ViewController: UIViewController {
    let localRealm = try! Realm()
    var tasks: Results<ShoppingList>!
    
    @IBOutlet weak var tableView: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        //네비게이션 바 설정
        title = "샤핑 리수투"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .plain, target: self, action: #selector(sortAlert))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: #selector(deleteAlert))
        
        //realm 데이터 가져오기
        tasks = localRealm.objects(ShoppingList.self).sorted(byKeyPath: "regDate", ascending: false) // 최근 등록일 순
     
    }
    
    //삭제, 백업 및 복구
    @objc func deleteAlert(){
        let alert = UIAlertController(title: "삭제", message: nil, preferredStyle: .actionSheet)
        
        let allDelete = UIAlertAction(title: "전체 삭제", style: .default) { (action) in
            try! self.localRealm.write{
                self.localRealm.deleteAll()
                self.tableView.reloadData()
            }
            return
        }
        let confirmedDelete = UIAlertAction(title: "체크 항목 삭제", style: .default){ (action) in
            let data = self.localRealm.objects(ShoppingList.self).filter("confirmed == true")
            try! self.localRealm.write{
                self.localRealm.delete(data)
                self.tableView.reloadData()
            }
            return
        }
        let exceptStarDelete = UIAlertAction(title: "즐겨찾기 빼고 삭제", style: .default){ (action) in
            let data = self.localRealm.objects(ShoppingList.self).filter("favorite == false")
            try! self.localRealm.write{
                self.localRealm.delete(data)
                self.tableView.reloadData()
            }
            return
        }
        let backup = UIAlertAction(title: "백업", style: .default){ (action) in
            //백업할 파일에 대한 URL 배열
            var urlPaths = [URL]()
            
            //도큐먼트 폴더 위치
            if let path = self.documentDirectoryPath(){
                //백업하고자 하는 파일 URL 확인
                let realm = (path as NSString).appendingPathComponent("default.realm")
                //2. 백업하고자 하는 파일 존재 여부 확인
                if FileManager.default.fileExists(atPath: realm){
                    //5. URL배열에 백업 파일 URL 추가
                    urlPaths.append(URL(string: realm)!)
                }
                else{
                    print("백업할 파일이 없습니다.")
                }
            }
            //배열에 대해 압축 파일 만들기
            do {
                let zipFilePath = try Zip.quickZipFiles(urlPaths, fileName: "archive") // Zip
                print("압축 경로: \(zipFilePath)")
                self.presentActivityViewController()
            }
            catch {
              print("압축 ㄴ")
            }
            return
        }
        let restore = UIAlertAction(title: "복구", style: .default){ (action) in
            let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeArchive as String], in: .import)
            documentPicker.delegate = self
            documentPicker.allowsMultipleSelection = false // 여러개 선택 가능한지
            self.present(documentPicker, animated: true, completion: nil)
            return
        }
        let noAction = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(allDelete)
        alert.addAction(confirmedDelete)
        alert.addAction(exceptStarDelete)
        alert.addAction(backup)
        alert.addAction(restore)
        alert.addAction(noAction)
        present(alert, animated: true, completion: nil)
    }
    
    //도큐먼트 폴더 위치
    func documentDirectoryPath() -> String?{
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let path = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
        
        if let directoryPath = path.first{
            return directoryPath
        }
        else{
            return nil
        }
        
    }
    //공유 화면
    func presentActivityViewController(){
        //압축 파일 경로 가져오기
        let fileName = (documentDirectoryPath()! as NSString).appendingPathComponent("archive.zip")
        let fileURL = URL(fileURLWithPath: fileName)
        let vc = UIActivityViewController(activityItems: [fileURL], applicationActivities: [])
        
        self.present(vc, animated: true, completion: nil)
        
    }
    
    
    //정렬
    @objc func sortAlert(){
        
        let alert = UIAlertController(title: "정렬", message: nil, preferredStyle: .actionSheet)
        
        let dateSort = UIAlertAction(title: "최근등록순", style: .default) { (action) in
            self.tasks = self.localRealm.objects(ShoppingList.self).sorted(byKeyPath: "regDate", ascending: false)
            self.tableView.reloadData()
            return
        }
        let willdoSort = UIAlertAction(title: "체크안된순", style: .default){ (action) in
            //self.tasks = self.localRealm.objects(ShoppingList.self).filter("confirmed == false") //안한것만 보기
            self.tasks = self.localRealm.objects(ShoppingList.self).sorted(byKeyPath: "confirmed", ascending: true) // 안한거 상위 노출
            self.tableView.reloadData()
            return
        }
        let starSort = UIAlertAction(title: "즐겨찾기순", style: .default){ (action) in
            //self.tasks = self.localRealm.objects(ShoppingList.self).filter("favorite == true")
            self.tasks = self.localRealm.objects(ShoppingList.self).sorted(byKeyPath: "favorite", ascending: false) // 즐겨찾기 노출
            self.tableView.reloadData()
        }
        let contentSort = UIAlertAction(title: "가나다순", style: .default){ (action) in
            self.tasks = self.localRealm.objects(ShoppingList.self).sorted(byKeyPath: "shoppingContent", ascending: true)
            self.tableView.reloadData()
            return
        }
        let noAction = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(dateSort)
        alert.addAction(willdoSort)
        alert.addAction(starSort)
        alert.addAction(contentSort)
        alert.addAction(noAction)
        present(alert, animated: true, completion: nil)
        
    }
    
   
    
    
    //체크 박스
    @IBAction func checkButtonClicked(_ sender: UIButton) {
        //레코드에 대한 값 수정
        let taskUpdate = tasks[sender.tag]
        try! localRealm.write{
            taskUpdate.confirmed = !taskUpdate.confirmed
            tableView.reloadData()
        }
    
    }
    
    //즐겨 찾기
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
            
            //셀 안 추가 버튼 액션 클로저로 구현
            //unowned self 를 쓴 이유는 retain 싸이클을 방지하기 위해서 사용 (좀 더 개념적으로 확인 필요)
            cell.add = { [unowned self] in
                
                //공백일 경우 토스트 띄어주고 리턴
                if cell.purchaseTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
                    let windows = UIApplication.shared.windows
                                windows.last?.makeToast("구매할 목록을 입력하세요!", duration: 3.0, position: .top)
                    return
                }
                
                //중복된 내용이면 물어보기
                if !localRealm.objects(ShoppingList.self).filter("shoppingContent == '\(cell.purchaseTextField.text!)'").isEmpty{
                    
                    let alert = UIAlertController(title: cell.purchaseTextField.text!, message: "이미 있는 항목이어도 추가하시겠습니까?", preferredStyle: .alert)
                    let yesAction = UIAlertAction(title: "예", style: .default){ (action) in
                        let task = ShoppingList(shoppingContent: cell.purchaseTextField.text!, confirmed: false, favorite: false, regDate: Date())
                
                        try! localRealm.write {
                            localRealm.add(task)
                        }
                        self.tableView.reloadData()
                        return
                    }
                    let noAction = UIAlertAction(title: "아니오", style: .cancel){ (action) in
                        return
                    }
                    alert.addAction(yesAction)
                    alert.addAction(noAction)
                    present(alert, animated: true, completion: nil)
                }
                //중복 아니면 그냥 추가
                else{
                    let task = ShoppingList(shoppingContent: cell.purchaseTextField.text!, confirmed: false, favorite: false, regDate: Date())
            
                    try! localRealm.write {
                        localRealm.add(task)
                    }
                   self.tableView.reloadData()
                }
                
                
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
        let row = tasks[indexPath.row]
        try! localRealm.write{
            localRealm.delete(row)
            tableView.reloadData()
        }
    }
}
extension ViewController: UIDocumentPickerDelegate{
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("취소됐을때")
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        //선택한 파일에 대한 경로를 가져와야함
        guard let selectedFileURL = urls.first else { return }
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let sandboxFileURL = directory.appendingPathComponent(selectedFileURL.lastPathComponent)
        
        //압축 해제
        if FileManager.default.fileExists(atPath: sandboxFileURL.path){
            //기존에 복구하고자 하는 zip파일을 도큐먼트에 가지고 있을 경우, 도큐먼트에 위치한 zip파일을 압축 해제 하면 됨
            do{
                let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileURL = documentDirectory.appendingPathComponent("archive.zip")
                
                try Zip.unzipFile(fileURL, destination: documentDirectory, overwrite: true, password: nil, progress: { progress in
                    print(progress)
                }, fileOutputHandler: { unzippedFile in
                    print("unzippedFile : \(unzippedFile) ")
                    
                    let alert = UIAlertController(title: "복구 완료", message: "앱을 재실행 해주세요", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "확인", style: .default){ (action) in
                        exit(0)
                    }
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                })
            }
            catch{
                print("아ㅏㅏ ")
            }
            
        }
        else{
            //파일 앱의 zip -> 도큐먼트 폴더에 복사
            do{
                try FileManager.default.copyItem(at: selectedFileURL, to: sandboxFileURL)
                
                let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileURL = documentDirectory.appendingPathComponent("archive.zip")
                
                try Zip.unzipFile(fileURL, destination: documentDirectory, overwrite: true, password: nil, progress: { progress in
                    print(progress)
                }, fileOutputHandler: { unzippedFile in
                    print("unzippedFile : \(unzippedFile) ")
                    
                    let alert = UIAlertController(title: "복구 완료", message: "앱을 재실행 해주세요", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "확인", style: .default){ (action) in
                        exit(0)
                    }
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                })
            }
            catch{
                print("노오오")
            }
        }
        
    }
    
}

// 쇼핑 리스트 추가 섹션 셀
class ShoppingAddCell: UITableViewCell, UITextFieldDelegate{
    
    @IBOutlet weak var purchaseAddButton: UIButton!
    @IBOutlet weak var purchaseTextField: UITextField!
    var add : (() -> ()) = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        purchaseTextField.delegate = self
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            guard let text = textField.text else { return true }
            let newLength = text.count + string.count - range.length
            return newLength <= 15 // 글자 제한
    }
    
    @IBAction func addButtonClicked(_ sender: UIButton) {
        add()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        add()
        return true
    }
    
}


// 쇼핑 리스트 셀
class ShoppingListCell: UITableViewCell{
    
    @IBOutlet weak var purchaseLabel: UILabel!
    @IBOutlet weak var confirmedCheckButton: UIButton!
    @IBOutlet weak var favoritStarButton: UIButton!
    
    
}

