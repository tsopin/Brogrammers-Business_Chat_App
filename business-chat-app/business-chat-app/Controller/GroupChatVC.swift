//
//  GroupChatVC.swift
//  business-chat-app
//
//  Created by Timofei Sopin on 2018-03-17.
//  Copyright © 2018 Brogrammers. All rights reserved.
//

import UIKit
import Firebase
import SimpleImageViewer
import SVProgressHUD

class GroupChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  @IBOutlet var mainView: UIView!
  @IBOutlet weak var textInputView: UIView!
  @IBOutlet weak var chatTableView: UITableView!
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var sendBtn: UIButton!
  @IBOutlet weak var heightConstraint: NSLayoutConstraint!
  
  let customMessageIn = CustomMessageIn()
  let customMessageOut = CustomMessageOut()
  let imagePickerContorller = UIImagePickerController()
  
  let colours = Colors()
  
  let dateFormatter = DateFormatter()
  let now = NSDate()
  var chat: Chat?
  var chatMessages = [Message]()
  
  func initData(forChat chat: Chat){
    self.chat = chat
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Check chat name and set title (in case it was changed)
    ChatServices.instance.REF_CHATS.child((chat?.key)!).observeSingleEvent(of: .value) { (snapshot) in
      let value = snapshot.value as? NSDictionary
      let chatName = value!["chatName"] as? String ?? ""
      self.title = chatName
      
    }
  }
  
  
  func getMessages() {
    MessageServices.instance.REF_MESSAGES.child((self.chat?.key)!).observe(.childAdded) { (snapshot) in
      MessageServices.instance.getAllMessagesFor(desiredChat: self.chat!, handler: { (returnedChatMessages) in
        self.chatMessages = returnedChatMessages
        DispatchQueue.main.async {
          self.configureTableView()
        }
        self.chatTableView.reloadData()
        
        self.scrollToBottom()
        
      })
    }
  }
  
  func scrollToBottom() {
    if self.chatMessages.count - 1 <= 0 {
      return
    }
    let indexPath = IndexPath(item: self.chatMessages.count - 1, section: 0)
    DispatchQueue.main.async {
      self.chatTableView?.scrollToRow(at: indexPath, at: .top, animated: false)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    NotificationCenter.default.addObserver(self, selector:#selector(GroupChatVC.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector:#selector(GroupChatVC.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    
    chatTableView.delegate = self
    chatTableView.dataSource = self
    textField.delegate = self
    imagePickerContorller.delegate = self
    
    chatTableView.register(UINib(nibName: "CustomMessageIn", bundle: nil), forCellReuseIdentifier: "messageIn")
    chatTableView.register(UINib(nibName: "CustomMessageOut", bundle: nil), forCellReuseIdentifier: "messageOut")
    
    chatTableView.register(UINib(nibName: "MultimediaMessageIn", bundle: nil), forCellReuseIdentifier: "multimediaMessageIn")
    chatTableView.register(UINib(nibName: "MultimediaMessageOut", bundle: nil), forCellReuseIdentifier: "multimediaMessageOut")
    
    //    self.hideKeyboardWhenTappedAround()
    configureTableView()
    getMessages()
    chatTableView.separatorStyle = .none
    
    textInputView.layer.borderWidth = 1
    textInputView.layer.borderColor = colours.backgroundLigthBlue.cgColor
    
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
    
    let outColor = colours.colourMainBlue
    let inColor = colours.colourMainGreen
    let sender = chatMessages[indexPath.row].senderId
    let isMedia = chatMessages[indexPath.row].isMultimedia
    let mediaUrl = chatMessages[indexPath.row].mediaUrl
    let content = chatMessages[indexPath.row].content
    
    if  sender == currentUserId {
      
      if isMedia == true || content.contains(".gif") || content.contains(".jpg") {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "multimediaMessageOut", for: indexPath) as! MultimediaMessageOut
        let date = getDateFromInterval(timestamp: Int64(chatMessages[indexPath.row].timeSent))
        
        cell.configureCell(messageImage: mediaUrl, messageTime: date!, senderName: sender)
        return cell
        
      }
      
      // WebView CEll
      //        else if url != nil {
      //        let cell = tableView.dequeueReusableCell(withIdentifier: "webOut", for: indexPath) as! WebCellOut
      //        let date = getDateFromInterval(timestamp: Double(chatMessages[indexPath.row].timeSent))
      //
      //        cell.configureCell(mediaUrl: content, messageTime: date!, senderName: sender)
      //        return cell
      //      }
      
      let cell = tableView.dequeueReusableCell(withIdentifier: "messageOut", for: indexPath) as! CustomMessageOut
      let date = getDateFromInterval(timestamp: Int64(chatMessages[indexPath.row].timeSent))
      
      cell.configureCell(senderName: currentEmail!, messageTime: date!, messageBody: content, messageBackground: outColor!, isGroup: false)
      return cell
      
    } else {
      
      if isMedia == true || content.contains(".gif") || content.contains(".jpg") {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "multimediaMessageIn", for: indexPath) as! MultimediaMessageIn
        let date = getDateFromInterval(timestamp: Int64(chatMessages[indexPath.row].timeSent))
        
        cell.configureCell(messageImage: mediaUrl, messageTime: date!, senderName: sender)
        
        return cell
      }
      
      let cell = tableView.dequeueReusableCell(withIdentifier: "messageIn", for: indexPath) as! CustomMessageIn
      let date = getDateFromInterval(timestamp: Int64(chatMessages[indexPath.row].timeSent))
      
      cell.configureCell(senderName: chatMessages[indexPath.row].senderId, messageTime: date!, messageBody: chatMessages[indexPath.row].content, messageBackground: inColor!, isGroup: false)
      return cell
      
    }
  }
  
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    
    UIView.animate(withDuration: 0.2) {
      
      self.heightConstraint.constant = 60
      self.view.layoutIfNeeded()
      
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    let currentCell = chatTableView.cellForRow(at: indexPath)
    
    if (currentCell?.isKind(of: MultimediaMessageIn.self))! {
      print("MULIT IN")
      let cell = chatTableView.cellForRow(at: indexPath) as! MultimediaMessageIn
      
      let configuration = ImageViewerConfiguration { config in
        config.imageView = cell.messageBodyImage
      }
      present(ImageViewerController(configuration: configuration), animated: true)
      
    }else if (currentCell?.isKind(of: MultimediaMessageOut.self))! {
      print("MULIT Out")
      let cell = chatTableView.cellForRow(at: indexPath) as! MultimediaMessageOut
      
      let configuration = ImageViewerConfiguration { config in
        config.imageView = cell.messageBodyImage
      }
      present(ImageViewerController(configuration: configuration), animated: true)
    }
    
  }
  
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return chatMessages.count
  }
  
  @IBAction func photoButton(_ sender: Any) {
    
    let actionSheet = UIAlertController(title: "Select source of Image", message: "", preferredStyle: .actionSheet)
    
    actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction) in
      self.imagePickerContorller.sourceType = .camera
      self.present(self.imagePickerContorller, animated: true, completion: nil)
    }))
    
    actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action:UIAlertAction) in
      self.imagePickerContorller.sourceType = .photoLibrary
      self.present(self.imagePickerContorller, animated: true, completion: nil)
    }))
    
    actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel , handler: nil))
    
    self.present(actionSheet, animated: true, completion: nil)
    
    //    print("Photo Message Uploaded")
    
  }
  
  func sendMessage(){
    
    
    
    //    // Get URL from String
    var url = String()
    var content = textField.text!
    
    //
    
    let date = Date()
    let currentDate = Int64(date.millisecondsSince1970)
    let messageUID = MessageServices.instance.REF_MESSAGES.child((self.chat?.key)!).childByAutoId().key
    
    func isGif(isGif: Bool, withContent sendContent: String){
      MessageServices.instance.sendMessage(withContent: sendContent , withTimeSent: currentDate, withMessageId: messageUID, forSender: currentUserId! , withChatId: chat?.key, isMultimedia: isGif, sendComplete: { (complete) in
        if complete {
          self.textField.isEnabled = true
          self.sendBtn.isEnabled = true
          self.textField.text = ""
          print("Message saved \(currentDate)")
        }
      })
      
    }
    
    if content != "" {
      sendBtn.isEnabled = false
      isGif(isGif: false, withContent: content)
      
      if content.contains("http") && content.contains("gif")  {
        
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: content, options: [], range: NSRange(location: 0, length: content.utf16.count))
        
        for match in matches {
          guard let range = Range(match.range, in: content) else { continue }
          url = String(content[range])
          print("GIF URL \(url)")
        }
        
        sendBtn.isEnabled = false
        isGif(isGif: true, withContent: url)
        
      }
      dismissKeyboard()
      
      
      
    }
  }
  
  
  @IBAction func sendButton(_ sender: Any) {
    
    sendMessage()
  }
  
  @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String:Any]) {
    
    print("picked")
    
    SVProgressHUD.show(withStatus: "Sending Image")
    
    let image = info[UIImagePickerControllerOriginalImage] as! UIImage
    let date = Date()
    let currentDate = Int64(date.millisecondsSince1970)
    let messageUID = MessageServices.instance.REF_MESSAGES.child((self.chat?.key)!).childByAutoId().key
    
    Services.instance.uploadPhotoMessage(withImage: image, withChatKey: (self.chat?.key)!, withMessageId: messageUID, completion: { (imageUrl) in
      
      MessageServices.instance.sendPhotoMessage(isMulti: true, withMediaUrl: imageUrl, withTimeSent: currentDate, withMessageId: messageUID, forSender: currentUserId!, withChatId: self.chat?.key, sendComplete: { (complete) in
        self.textField.isEnabled = true
        self.sendBtn.isEnabled = true
        self.textField.text = ""
        if complete {
          print("Message saved \(currentDate)")
          SVProgressHUD.dismiss(withDelay: 0.5)
        } else {
          SVProgressHUD.showError(withStatus: "Uploading Error")
          SVProgressHUD.dismiss(withDelay: 0.5)
        }
      })
    })
    
    picker.dismiss(animated: true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }
  
  
  @objc func tableViewTapped() {
    chatTableView.endEditing(true)
  }
  
  
  func configureTableView() {
    chatTableView.rowHeight = UITableViewAutomaticDimension
    chatTableView.estimatedRowHeight = 120.0
  }
  
  @objc func keyboardWillShow(notification : NSNotification) {
    
    let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size
    
    self.heightConstraint.constant = keyboardSize.height + 60
    UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
      
    })
  }
  
  @objc func keyboardWillHide(notification : NSNotification) {
    self.heightConstraint.constant = 0
    
  }
  
  // MARK: -- Navigation --
  
  deinit{
    
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showGroupInfo" {
      let groupInfoVC = segue.destination as! GroupInfoVC
      groupInfoVC.initData(forChat: chat!)
    }
  }
  
  
  
  
}

