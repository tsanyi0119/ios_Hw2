//
//  MessageBoardViewController.swift
//  MessageBoard
//
//  Created by imac-1681 on 2023/1/17.
//

import UIKit

class MessageBoardViewController: UIViewController {
    
    @IBOutlet weak var messagePeopleLabel: UILabel!
    @IBOutlet weak var messagePeopleTextField: UITextField!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var arangeBtn: UIButton!
    
    var messageArray: [Message] = []
    var optionsArray:[String] = ["預設","舊到新","新到舊"]
    
    enum SortRule{
        //
        case `default`
        //
        case oldToNew
        //
        case newToOld
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI(){
        messagePeopleLabel.text = "留言人"
        messageLabel.text = "留言內容"
        setupTableView()
        setupButton()
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    private func setupTableView(){
        messageTableView.register(UINib(nibName: "MessageTableViewCell", bundle: nil), forCellReuseIdentifier: MessageTableViewCell.identifier)
        messageTableView.dataSource = self
        messageTableView.delegate = self
    }
    
    private func setupButton(){
        submitBtn.setTitle("送出", for: .normal)
        arangeBtn.setTitle("排序", for: .normal)
        submitBtn.layer.cornerRadius = 10
        submitBtn.layer.backgroundColor = UIColor.lightGray.cgColor
        arangeBtn.layer.cornerRadius = 10
        arangeBtn.layer.backgroundColor = UIColor.lightGray.cgColor
    }
    
    func sortMessage(rule:SortRule)->[Message]{
        return  messageArray.sorted(by: {prev,next in
            switch rule{
            case .default:
                return prev.timestamp > next.timestamp
            case .oldToNew:
                return prev.timestamp < next.timestamp
            case .newToOld:
                return prev.timestamp > next.timestamp
            }
        })
        
    }
    
    @IBAction func sortBtnClicked(_ sender: Any) {
        showActionSheet(title: "請選擇排序方式", message: "", options: optionsArray){
            index in
            switch index{
            case 0:
                print("選擇預設排序方式")
                print(self.sortMessage(rule: .default))
            case 1:
                print("選擇舊到新排序方式")
                print(self.sortMessage(rule: .oldToNew))
            case 3:
                print("選擇新到舊排序方式")
                print(self.sortMessage(rule: .newToOld))
            default:
                break
            }
        }
    }
    
    
    @IBAction func sendBtnClicked(_ sender: Any) {
        closeKeyboard()
        guard let messagePeople = messagePeopleTextField.text,!(messagePeople.isEmpty) else{
            showAlert(title: "錯誤", message: "請輸入留言人", confirmTitle: "關閉")
            return
        }
        guard let message = messageTextView.text,!(message.isEmpty) else{
            showAlert(title: "錯誤", message: "請輸入留言", confirmTitle: "關閉")
            return
        }
        showAlert(title: "成功", message: "留言已送出",confirmTitle: "關閉"){
            self.messagePeopleTextField.text = ""
            self.messageTextView.text = ""
        }
        print("留言人：\(messagePeopleTextField.text!)")
        print("留言內容：\(messageTextView.text!)")
        messageArray.append(Message(name: messagePeople, content: message, timestamp: Int64(Date().timeIntervalSince1970)))
        messageTableView.reloadData()
    }
    
    //關鍵盤
    @objc func closeKeyboard(){
        view.endEditing(true)
    }
    func showAlert(title:String?,message:String?,confirmTitle:String,confirm:(() -> Void)? = nil ){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: confirmTitle, style: .default){ _ in
            confirm?()
        }
        alertController.addAction(confirmAction)
        present(alertController, animated: true)
    }
    
    func showActionSheet(title:String?,message:String?,options:[String],confirm:((Int)->Void)? = nil){
        let alerController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        for i in options{
            let index = options.firstIndex(of: i)
            let action = UIAlertAction(title: i, style: .default){ _ in
                confirm?(index!)
            }
            alerController.addAction(action)
        }
        let cancelAction = UIAlertAction(title:"取消",style:.cancel)
        alerController.addAction(cancelAction)
        present(alerController, animated: true)
    }
    
}

extension MessageBoardViewController:UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView,numberOfRowsInSection senction:Int) -> Int{
        return messageArray.count
    }

    func tableView(_ tableView:UITableView,cellForRowAt indexPath:IndexPath) -> UITableViewCell{
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageTableViewCell.identifier, for: indexPath) as? MessageTableViewCell else{
            
            fatalError("MessageTableViewCell Load Failed")
            
        }
        cell.messagePeopleLabel.text = "留言人：" + messageArray[indexPath.row].name
        cell.messageLabel.text = "留言內容：" + messageArray[indexPath.row].content
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->CGFloat {
        return 100
    }
    //右滑
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "新增") { action,sourceView,completionHandler in
            self.messageArray.remove(at: indexPath.row)
            tableView.reloadData()
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName:"rays")
        deleteAction.backgroundColor = UIColor(red: 52/255, green: 120/255,blue: 246/255,alpha: 1)
        let configuration = UISwipeActionsConfiguration(actions:[deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    //左滑
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let renewAction = UIContextualAction(style: .destructive, title: "刪除") { action,sourceView,completionHandler in
            self.messageArray.remove(at: indexPath.row)
            tableView.reloadData()
            completionHandler(true)
        }
        renewAction.image = UIImage(systemName:"trash.square")
        renewAction.backgroundColor = UIColor(red: 246/255, green: 100/255,blue: 52/255,alpha: 1)
        let configuration = UISwipeActionsConfiguration(actions:[renewAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}
