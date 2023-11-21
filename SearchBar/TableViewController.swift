//
//  ViewController.swift
//  SearchBar
//
//  Created by Jorge Abalo Dieste on 21/11/23.
//


import UIKit

class MarvelViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource {
    
    
    
    @IBOutlet weak var SearchBar: UISearchBar!
    
  
    @IBOutlet weak var tableView: UITableView!
 
    var characters: [Character] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configuración inicial
        SearchBar.delegate = self
        tableView.dataSource = self
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text, !text.isEmpty else {
            return
        }
        searchCharacters(name: text)
        // Realizar la búsqueda con la API de Marvel aquí
        // Asegúrate de manejar la paginación si hay muchos resultados
        
        // Por ahora, utilizaremos una función de ejemplo para simular resultados
        searchCharacters(name: searchText)
    }
    func searchCharacters(name: String) {
        guard !name.isEmpty else {
            return
        }

        // Reemplaza con tus propias credenciales de la API de Marvel
        let publicKey = "4da961812496c30cf73ed692b494f315"
        let privateKey = "d7fc2827797d7e47f6417dca83b3beeb4c5607ee"

        let timestamp = "\(Date().timeIntervalSince1970)"
        let hash = (timestamp + privateKey + publicKey).md5

        // Construye la URL de la API de Marvel
        let baseURL = "https://gateway.marvel.com/v1/public/characters"
        let apiKeyParam = "apikey=\(publicKey)"
        let hashParam = "hash=\(hash)"
        let tsParam = "ts=\(timestamp)"
        let nameParam = "nameStartsWith=\(name)"

        let urlString = "\(baseURL)?\(apiKeyParam)&\(hashParam)&\(tsParam)&\(nameParam)"

        guard let url = URL(string: urlString) else {
            print("URL inválida")
            return
        }

        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error de red: \(error)")
                return
            }

            guard let data = data else {
                print("Datos nulos en la respuesta")
                return
            }

            do {
                let decoder = JSONDecoder()
                let marvelResponse = try decoder.decode(MarvelResponse.self, from: data)
                self.characters = marvelResponse.data.results

                // Actualizar la interfaz de usuario en el hilo principal
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }

            } catch let decodingError {
                print("Error al decodificar la respuesta: \(decodingError)")
            }
        }.resume()
    }

   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterCell", for: indexPath) as! CharacterCell
        
        let character = characters[indexPath.row]
        cell.characterNameLabel.text = character.name
        
        // Puedes manejar la carga de la imagen aquí según la URL de la imagen del personaje
        
        return cell
    }
}

struct MarvelResponse: Decodable {
    let data: MarvelData
}

struct MarvelData: Decodable {
    let results: [Character]
}

struct Character: Decodable {
    let id: Int
    let name: String
    // Puedes agregar más propiedades según la respuesta de la API
}

class CharacterCell: UITableViewCell {
    @IBOutlet weak var characterNameLabel: UILabel!
    // Puedes agregar más outlets según la celda personalizada
}
import Foundation
import CommonCrypto

extension String {
    var md5: String {
        let data = Data(utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))

        _ = data.withUnsafeBytes { (body: UnsafeRawBufferPointer) in
            CC_MD5(body.baseAddress, CC_LONG(data.count), &digest)
        }

        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}
