//
//  ViewController.swift
//  cadastro
//
//  Created by Virtual Machine on 15/06/22.
//

import UIKit

class ViewController: UIViewController {

    let service = Services()
    
    @IBOutlet weak var cepButton: UITextField!
    @IBOutlet weak var ruaButton: UITextField!
    @IBOutlet weak var bairroButton: UITextField!
    @IBOutlet weak var cidadeButton: UITextField!
    @IBOutlet weak var estadoButton: UITextField!	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        cepButton.delegate = self
        service.delegateCep = self
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
        cepButton.smartInsertDeleteType = UITextSmartInsertDeleteType.no
    }

    @objc func tap() {
        guard let cep = cepButton.text else {return}
        Validation(cep: cep)
        view.endEditing(true)
    }
                                       
    func Validation(cep: String){
            if cep.count == 8 {
                Formatting(cepUrl: cep)
            } else {
                let alert = UIAlertController(title: "Erro", message: "Verifique o CEP", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                print("ERRO")
                
            }
        }
    func Formatting(cepUrl: String){
            let cep = cepUrl.replacingOccurrences(of: " ", with: "+")
            let urlString = "\(service.cepURL)\(cep)/json/"
          service.requestCep(cepURL: urlString)
        }
}

extension ViewController: UITextFieldDelegate {
    
    @IBAction func cepTextfield(_ sender: Any){
       
        cepButton.endEditing(true)
        
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

               guard let textFieldText = textField.text,
                   let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                       return false
               }
               let substringToReplace = textFieldText[rangeOfTextToReplace]
               let count = textFieldText.count - substringToReplace.count + string.count
            if count == 8 {
                let cepAtual = String(textField.text! + string)
                Validation(cep: cepAtual)
            }
               return count <= 8
           }
}

extension ViewController: CepManegerDelegate {
    
    func didUpdateCep(cep: CepModel) {
        getData(response : cep)
    }
    
    func didError(erro: String, visivel: Bool) {
        if visivel == true {
            DispatchQueue.main.async {
                self.cepButton.text = erro
                self.cepButton.textColor = UIColor.red
            }
        } else {
        print(erro)
        }
    }
    
    func getData(response: CepModel?){
        if let safeResponse = response{
            DispatchQueue.main.async {
                self.ruaButton.text = safeResponse.logradouro
                self.bairroButton.text = safeResponse.bairro
                self.cidadeButton.text = safeResponse.localidade
                self.estadoButton.text = safeResponse.uf
            }
        }
    }
}
