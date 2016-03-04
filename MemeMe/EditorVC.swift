import UIKit

class EditorVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var actionButton: UIBarButtonItem!

    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!

    let topPlaceholderText = "TOP"
    let bottomPlaceholderText = "BOTTOM"
    var currentTextField: UITextField?
	var meme: Meme!

    @IBOutlet weak var memeImageView: UIImageView!

    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let memeTextAttributes = [
            NSStrokeColorAttributeName: UIColor.blackColor(),
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : CGFloat(-3.0)
        ]

        actionButton.enabled = false

        topText.defaultTextAttributes = memeTextAttributes
        bottomText.defaultTextAttributes = memeTextAttributes
        topText.textAlignment = NSTextAlignment.Center
        bottomText.textAlignment = NSTextAlignment.Center
        
        topText.delegate = self
        bottomText.delegate = self

		clrAndHideTxt()
 
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    }
    
    /// Runs when the view appears
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    /// Runs when the view disappears
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }

	// TEXT DELEGATE

    func textFieldDidBeginEditing(textField: UITextField) {
        clearPlaceholderText(textField)
        currentTextField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        showPlaceholderText(textField)
        currentTextField = nil
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // KEYBOARD

    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let textField = currentTextField {
            if textField == bottomText {
                self.view.frame.origin.y -= getKeyboardHeight(notification)
            }
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }

	// MEME

    private func makeMemeImage() -> UIImage {
		hideToolbars()
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        showToolbars()
        
        return image
    }

    private func save(comp: UIImage) {
	  let backgroundImage = self.memeImageView.image == nil ?
		UIImage() : self.memeImageView.image
	  Meme(
		topTxt:		self.topText.text!,
		btmTxt:		self.bottomText.text!,
		img:		backgroundImage!,
		composite:	comp
	  )
	}

	// TOOLBARS

    private func hideToolbars() {
	  navBar.hidden = true
	  bottomToolbar.hidden = true
    }
    
    private func showToolbars() {
	  navBar.hidden = false
	  bottomToolbar.hidden = false
    }

	// TEXT FIELDS

    private func clearPlaceholderText(textField: UITextField) {
        if textField == topText && textField.text! == topPlaceholderText{
            textField.text = ""
        }
        if textField == bottomText && textField.text! == bottomPlaceholderText{
            textField.text = ""
        }
    }
    
    private func showPlaceholderText(textField: UITextField) {
        if textField == topText && textField.text! == "" {
            textField.text = topPlaceholderText
        }
        if textField == bottomText && textField.text! == "" {
            textField.text = bottomPlaceholderText
        }
    }
   
    private func showTxt() {
	  self.topText.hidden = false
	  self.bottomText.hidden = false
    }

    private func clrAndHideTxt() {
	  self.topText.text = ""
	  self.bottomText.text = ""
	  self.topText.hidden = true
	  self.bottomText.hidden = true
    }

	// ACTIONS

    @IBAction func didPressAction(sender: UIBarButtonItem) {
        let image = makeMemeImage()
        let activity = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activity.completionWithItemsHandler = {
		(type: String?, completed: Bool, returnedItems: [AnyObject]?, error: NSError?) in
            if completed {
		  		self.save(image)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        presentViewController(activity, animated: true, completion: nil)
    }

    @IBAction func didPressCancel(sender: UIBarButtonItem) {
	  clrAndHideTxt()
	  self.memeImageView.hidden = true
	  dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didPressPhoto(sender: UIBarButtonItem) {
	  showPlaceholderText(topText)
	  showPlaceholderText(bottomText)

	  let picker = UIImagePickerController()
	  picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
	  picker.delegate = self
	  presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBAction func didPressCamera(sender: UIBarButtonItem) {
	  showPlaceholderText(topText)
	  showPlaceholderText(bottomText)

	  let picker = UIImagePickerController()
	  picker.sourceType = UIImagePickerControllerSourceType.Camera
	  picker.delegate = self
	  presentViewController(picker, animated: true, completion: nil)
    }

	// IMAGE PICKER

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
		self.memeImageView.hidden = false

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
		  memeImageView.image = image
		  actionButton.enabled = true
		  topText.hidden = false
		  bottomText.hidden = false
        }

        dismissViewControllerAnimated(true, completion: nil)
    }
}