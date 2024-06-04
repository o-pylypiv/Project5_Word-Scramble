//
//  ViewController.swift
//  Project5
//
//  Created by Olha Pylypiv on 17.01.2024.
//

import UIKit

class ViewController: UITableViewController {
    
    var allWords = [String]()
    var usedWords = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
        startGame()
    }
    
    @objc func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }

    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else {return}
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
        //let errorTitle: String
        //let errorMessage: String
        
        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    if title?.lowercased() != lowerAnswer {
 
                        usedWords.insert(answer.lowercased(), at: 0)
                        
                        let indexPath = IndexPath(row: 0, section: 0)
                        tableView.insertRows(at: [indexPath], with: .automatic)
                        
                        return
                    } else {
                        showErrorMessage(errorTitle: "Word doesn't count", errorMessage: "Do not repeat the title")
                        //errorTitle = "Word doesn't count"
                        //errorMessage = "Do not repeat the title"
                    }
                } else {
                    showErrorMessage(errorTitle: "Word not recognized", errorMessage: """
                    You can't just make them up, you know!
                    Word should be more than 2 characters long.
                    """)
                    //errorTitle = "Word not recognized"
                    //errorMessage = """
                    //You can't just make them up, you know!
                    //Word should be more than 2 characters long.
                    //"""
                }
            } else {
                showErrorMessage(errorTitle: "Word already used", errorMessage: "Be more original")
                //errorTitle = "Word already used"
                //errorMessage = "Be more original"
            }
        } else {
            showErrorMessage(errorTitle: "Word not possible", errorMessage: "You can't spell that word from \(title?.lowercased() ?? "the provided word")")
            //guard let title = title else {return}
            //errorTitle = "Word not possible"
            //errorMessage = "You can't spell that word from \(title.lowercased())"
        }
        
        //let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        //ac.addAction(UIAlertAction(title: "Ok", style: .default))
        //present(ac, animated: true)
    }
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else {return false}
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        //return !usedWords.description.lowercased().contains(word.lowercased())
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        
        let range = NSRange(location: 0, length: word.utf16.count)
        
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        if misspelledRange.location == NSNotFound {
            if word.count > 2 {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    func showErrorMessage(errorTitle: String, errorMessage: String) {
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)
    }

}

