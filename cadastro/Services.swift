//
//  Services.swift
//  cadastro
//
//  Created by Virtual Machine on 15/06/22.
//
import Foundation
protocol CepManegerDelegate: NSObjectProtocol {
    func didUpdateCep(cep: CepModel)
    func didError(erro: String, visivel: Bool)
}

class Services {
    
    let cepURL = "https://viacep.com.br/ws/"
    var delegateCep: CepManegerDelegate?
    
    func requestCep(cepURL: String){

        var request = URLRequest(url: URL(string: cepURL )!)
        request.httpMethod = "GET"
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { [self] data, response, error in
            if error == nil {
                guard let response = response as? HTTPURLResponse else { return }
                if response.statusCode == 200 {
                    
                    if let safeData = data {
                        do {
                            let cep = try self.parseJSONCep(safeData)
                            if cep == nil {
                                delegateCep?.didError(erro: "Erro CEP nao encontrado", visivel: true)
                            } else {
                                delegateCep?.didUpdateCep(cep: cep!)
                            }
                        } catch {
                            delegateCep?.didError(erro: "Error Decode : \(error.localizedDescription)", visivel: false)
                        }
                    } else {
                        delegateCep?.didError(erro: "Error nos Dados: \(error)", visivel: false)
                    }
                } else {
                    delegateCep?.didError(erro: "Status invalido: \(response.statusCode)", visivel: false)
                }
            } else {
                delegateCep?.didError(erro: "Erro resposta nula: \(error?.localizedDescription)", visivel: false)
            }
        }
        task.resume()
    }
    
    func parseJSONCep(_ cepData: Data) -> CepModel? {
        let decoder = JSONDecoder()
        do {
            let decodeData = try decoder.decode(CepModel.self, from: cepData)
            return decodeData
        } catch {
            print("Error decodeJson \(error)")
            return nil
        }
    }
    
}
